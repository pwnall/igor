# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
    
  include UserFilters
  
  before_filter :extract_user_filter
  
  # filtering out file_upload due to its size, not for confidentiality
  filter_parameter_logging :password, :password_confirmation,
                           :file_upload

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '03ce602b284f2dc28ba716c5f8820ac1'
end
