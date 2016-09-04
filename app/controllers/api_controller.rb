class ApiController < ApplicationController
  skip_before_action :authenticate_using_session
  authenticates_using_http_token

  def user_info
    render json: { id: current_user.exuid }
  end
end
