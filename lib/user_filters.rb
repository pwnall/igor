module UserFilters
  # (before-filter) ensures that the session belongs to a registered user
  def authenticated_as_user    
    return bounce_user('Login required') if current_user.nil?
    return true if current_user.email_credential.key == '1'
    
    # inactive user
    session[:user_id] = nil
    bounce_user
  end
  
  # (before-filter) ensures that the session belongs to an administrator
  def authenticated_as_admin
    return false unless authenticated_as_user
    return true if current_user.admin
    
    bounce_user
  end
end
