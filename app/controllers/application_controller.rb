class ApplicationController < ActionController::Base
  protect_from_forgery

  include UserFilters
  
  before_filter :extract_user_filter
  
  # filtering out file_upload due to its size, not for confidentiality
  filter_parameter_logging :password, :password_confirmation,
                           :file_upload
end
