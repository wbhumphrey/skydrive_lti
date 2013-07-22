class FilesController < ApplicationController
  # before_filter :ensure_authenticated_user

  def index
    # if current_user.skydrive_token
    #   render json: {}, status: 401
    # else
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
  # end
end
