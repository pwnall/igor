class ApplicationController < ActionController::Base
  protect_from_forgery

  include UserFilters
  
  include AuthpwnHelper
  
  before_filter :extract_user_filter
  
  layout :layout_decider
  
  def layout_decider
    current_user ? 'application' : 'welcome'
  end
end
