class FilesController < ApplicationController
  before_filter :ensure_authenticated_user
  before_filter :ensure_valid_skydrive_token

  def ensure_valid_skydrive_token
    head :unauthorized unless current_user.valid_skydrive_token?

    if current_user.skydrive_token.not_before > Time.now
      client = Skydrive::Client.new(SHAREPOINT.merge(client_domain: current_user.skydrive_token.client_domain))
      results = client.refresh_token(current_user.skydrive_token.refresh_token)
      current_user.skydrive_token.update_attributes(results)
    end
  end

  def index
    puts "GUID: #{params[:guid]}"

    if params[:guid] == 'stuvw'
      render json: {
        parent_folder: { guid: 'xyzab' },
        guid: 'stuvw',
        name: 'Shared with Everyone',
        icon: '/images/icon-folder.png',
        folders: [],
        files: [
          {
            guid: 'abcde',
            icon: '/images/icon-word.png',
            name: 'Test.docx',
            kind: 'document',
            suffix: 'docx',
            size: 18290,
            url: 'https://instructure-my.sharepoint.com/personal/ericb_instructure_onmicrosoft_com/Documents/Shared with Everyone/Test.docx'
          }
        ]
      }
    else
      render json: {
        guid: 'xyzab',
        name: 'My Documents',
        folders: [
          {
            parent_folder: { guid: 'xyzab' },
            guid: 'stuvw',
            name: 'Shared with Everyone',
            icon: '/images/icon-folder.png',
            folders: [],
            files: [
              {
                guid: 'abcde',
                icon: '/images/icon-word.png',
                name: 'Test.docx',
                kind: 'document',
                suffix: 'docx',
                size: 18290,
                url: 'https://instructure-my.sharepoint.com/personal/ericb_instructure_onmicrosoft_com/Documents/Shared with Everyone/Test.docx'
              }
            ]
          }
        ],
        files: [
          {
            guid: 'fghij',
            icon: '/images/icon-pdf.png',
            name: 'TerryMooreTranscript.pdf',
            kind: 'document',
            suffix: 'pdf',
            size: 294536,
            url: 'https://instructure-my.sharepoint.com/personal/personal/ericb_instructure_onmicrosoft_com/Documents/TerryMooreTranscript04042013.pdf'
          },
          {
            guid: 'klmno',
            icon: '/images/icon-file.png',
            name: 'UtahJS-Logo.eps',
            kind: 'image',
            suffix: 'eps',
            size: 423139,
            url: 'https://instructure-my.sharepoint.com/personal/personal/ericb_instructure_onmicrosoft_com/Documents/UtahJS-Logo.eps'
          }
        ]
      }
    end
  end
end
