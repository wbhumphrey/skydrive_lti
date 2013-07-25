class User < ActiveRecord::Base
  has_many :api_keys
  has_one :skydrive_token

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true

  def session_api_key
    api_keys.active.session.create
  end

  def cleanup_api_keys
    api_keys.inactive.each(&:destroy)
  end

  def valid_skydrive_token?
    self.skydrive_token && self.skydrive_token.access_token
  end
end
