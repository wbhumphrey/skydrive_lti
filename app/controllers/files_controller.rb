class FilesController < ApplicationController
  before_filter :ensure_authenticated_user

  def index
    binding.pry
    if current_user.skydrive_token
      render json: {}, status: 401
    else

    end
  end
end
