class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  authenticates_using_session

  before_action do
    if current_user && current_user.email_credential.verified?
      Rack::MiniProfiler.authorize_request if current_user.admin?
    end
  end

  include CourseFilters
  include UserFilters
  include RouteHelpers
end
