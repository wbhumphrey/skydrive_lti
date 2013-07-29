require 'test_helper'

class SkydriveClientTest < ActiveSupport::TestCase
  test "generates access token" do
    @client = Skydrive::Client.new(SHAREPOINT.merge(
                     client_domain: 'instructure-my.sharepoint.com',
                     token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik5HVEZ2ZEstZnl0aEV1THdqcHdBSk9NOW4tQSJ9.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvaW5zdHJ1Y3R1cmUtbXkuc2hhcmVwb2ludC5jb21ANGIxM2E2MDgtYzI0OC00YmQxLTkwMTctMjc5NGMwZDdlNWM1IiwiaXNzIjoiMDAwMDAwMDEtMDAwMC0wMDAwLWMwMDAtMDAwMDAwMDAwMDAwQDRiMTNhNjA4LWMyNDgtNGJkMS05MDE3LTI3OTRjMGQ3ZTVjNSIsIm5iZiI6MTM3NTEyODAzOSwiZXhwIjoxMzc1MTcxMjM5LCJuYW1laWQiOiIxMDAzMDAwMDg2NzAxMDhjIiwiYWN0b3IiOiIwMGE4NzhhMy1mZGU3LTQ3YTMtOWM4OS0zYzk5MTJlNmJiODNANGIxM2E2MDgtYzI0OC00YmQxLTkwMTctMjc5NGMwZDdlNWM1IiwiaWRlbnRpdHlwcm92aWRlciI6InVybjpmZWRlcmF0aW9uOm1pY3Jvc29mdG9ubGluZSJ9.X805VxjOyR7Y0ozrpicxIfIjYOExXkpmRXA7eK8fyAjC4E3ovxzAzhJQUNp7w2hS6m1x30leo6myYm3q2jDwX6OR8GIRp9I7Noq1gtxWjlykeaIliL826082Yk7UymIaTfWSJsoqq6SurkKylWZkrK4406-jHNWECguVlBxXEE5-aJmV1afAx-5Q_hMfZET5ma1H8whWpMggKa-G150a6o4i4cmn_8sJeArC00R-x74gs1DCEJYMj_TWf8Out_G8wGawI6zPcj-CCiF10TTgftq_B_DB3YggdasrOWwW88i1lF-EZNaxYKSTx9DszkQbYCHNDpVYOK_Xc2ujdy4zQw"))

    personal_url = "https://instructure-my.sharepoint.com/personal/ericb_instructure_onmicrosoft_com/"
    data = @client.api_call(personal_url + "_api/web/lists/Documents/")

    folder = @client.get_folder_and_files(data['RootFolder']['__deferred']['uri'])

    # root_folder = @client.api_call(data['RootFolder']['__deferred']['uri'])
    # root_files = @client.api_call(root_folder['Files']['__deferred']['uri'])['results']
    # sub_folders = @client.api_call(root_folder['Folders']['__deferred']['uri'])['results']

    # my_documents = Skydrive::Folder.new
    # my_documents.name = root_folder['Name']
    # my_documents.server_relative_url = root_folder['ServerRelativeUrl']
    # my_documents.files = []
    # my_documents.folders = []

    # root_files.each do |f|
    #   new_file = Skydrive::File.new
    #   new_file.length = f['Length']
    #   new_file.name = f['Name']
    #   new_file.server_relative_url = f['ServerRelativeUrl']
    #   new_file.time_created = Date.parse(f['TimeCreated'])
    #   new_file.time_last_modified = Date.parse(f['TimeLastModified'])
    #   new_file.title = f['Title']
    #   new_file.content_tag = f['ContentTag']

    #   my_documents.files << new_file
    # end

    # sub_folders.each do |sf|
    #   subf = Skydrive::Folder.new
    #   subf.name = sf['Name']
    #   subf.server_relative_url = sf['ServerRelativeUrl']
    #   subf.files = []
    #   subf.folders = []
    #   my_documents.folders << subf
    # end

    # binding.pry

    # items_url = data["Items"]["__deferred"]["uri"]
    # items = @client.api_call(items_url)['results']
    # files = []
    # items.each do |item|
    #   if item['Title'].present?
    #     # This is a folder
    #   else
    #     # This is a file
    #     item_file_url = item['File']['__deferred']['uri']
    #   end
        
    #   files << @client.api_call(item_file_url)['results']
    # end
    # puts items.inspect
    # binding.pry
  end
end
