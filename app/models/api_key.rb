class ApiKey < ActiveRecord::Base
  validates :scope, inclusion: { in: %w( session api ) }
  #before_create :generate_access_token, :set_expiry_date
  before_create :generate_code, :set_expiry_date
  belongs_to :user

  scope :session,     -> { where(scope: 'session') }
  scope :api,         -> { where(scope: 'api') }
  scope :active,      -> { where("expired_at >= ?", Time.now) }
  scope :inactive,    -> { where("expired_at < ?", Time.now) }

  private

  def set_expiry_date
    self.expired_at = if self.scope == 'session'
                        30.minutes.from_now
                      else
                        #we should only have session keys for now
                        Time.now
                      end
  end

  def generate_code
    self.oauth_code = SecureRandom.uuid
  end

  def self.trade_oauth_code_for_access_token(oauth_code)
    api_key = ApiKey.active.where(oauth_code: oauth_code).first if oauth_code
    api_key.update(access_token: SecureRandom.uuid, oauth_code: nil) if api_key
    api_key
  end
end
