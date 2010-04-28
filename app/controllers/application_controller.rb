class ApplicationController < ActionController::Base
  protect_from_forgery

  include UserFilters
  
  before_filter :extract_user_filter
end
