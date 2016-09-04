class ApiController < ApplicationController
  skip_before_action :authenticate_using_session
  authenticates_using_http_token
  before_action :authenticated_as_user

  # GET /_/api/0/user_info
  def user_info
    @user = current_user
  end
end
