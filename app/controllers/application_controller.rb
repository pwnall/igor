class ApplicationController < ActionController::Base
  authenticates_using_session
  protect_from_forgery

  include UserFilters
end
