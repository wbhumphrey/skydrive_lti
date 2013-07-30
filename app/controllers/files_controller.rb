class FilesController < ApplicationController
  before_filter :ensure_authenticated_user
  before_filter :ensure_valid_skydrive_token

  def ensure_valid_skydrive_token
    head :unauthorized unless current_user.valid_skydrive_token?

    if current_user.skydrive_token.not_before > Time.now
      results = client.refresh_token(current_user.skydrive_token.refresh_token)
      current_user.skydrive_token.update_attributes(results)
    end
  end

  def client
    @client ||= Skydrive::Client.new(SHAREPOINT.merge(
                     client_domain: current_user.skydrive_token.client_domain,
                     token: current_user.skydrive_token.access_token))
  end

  def index
    uri = params[:uri]
    uri = nil if uri == 'root' || uri == 'undefined'
    has_parent = true
    unless uri.present?
      personal_url = current_user.skydrive_token.personal_url
      data = client.api_call(personal_url + "_api/web/lists/Documents/")
      uri = data['RootFolder']['__deferred']['uri']
      has_parent = false
    end
    folder = client.get_folder_and_files(uri)
    folder.parent_uri = nil unless has_parent
    render json: folder
  end
end
