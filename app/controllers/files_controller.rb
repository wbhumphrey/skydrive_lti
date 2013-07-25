class FilesController < ApplicationController
  before_filter :ensure_authenticated_user
  before_filter :ensure_valid_skydrive_token

  def ensure_valid_skydrive_token
    head :unauthorized unless current_user.valid_skydrive_token?

    if current_user.skydrive_token.not_before > Time.now
      binding.pry
      client = Skydrive::Client.new(SHAREPOINT.merge(client_domain: current_user.skydrive_token.client_domain))
      results = client.refresh_token(current_user.skydrive_token.refresh_token)
      current_user.skydrive_token.update_attributes(results)
    end
  end

  def index
    render json: {
      name: 'My Documents',
      folders: [
        {
          name: 'Shared with Everyone',
          folders: [],
          files: [
            {
              name: 'Test.docx',
              content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              size: 18290,
              url: 'https://instructure-my.sharepoint.com/personal/ericb_instructure_onmicrosoft_com/Documents/Shared with Everyone/Test.docx'
            }
          ]
        }
      ],
      files: [
        {
          name: 'TerryMooreTranscript.pdf',
          content_type: 'application/pdf',
          size: 294536,
          url: 'https://instructure-my.sharepoint.com/personal/personal/ericb_instructure_onmicrosoft_com/Documents/TerryMooreTranscript04042013.pdf'
        },
        {
          name: 'UtahJS-Logo.eps',
          content_type: 'image/x-eps',
          size: 423139,
          url: 'https://instructure-my.sharepoint.com/personal/personal/ericb_instructure_onmicrosoft_com/Documents/UtahJS-Logo.eps'
        }
      ]
    }
  end
end
