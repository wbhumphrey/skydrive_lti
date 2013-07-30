module Skydrive
  class Folder
    attr_accessor :uri, :parent_uri, :name, :server_relative_url, :files, :folders, :icon
  end
end