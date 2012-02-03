module UserFilters
  # (before-filter) ensures that the session belongs to a registered user
  def authenticated_as_user    
    return bounce_user('Login required') if current_user.nil?
    return true if current_user.email_credential.verified?
    
    # Inactive user.
    self.current_user = nil
    bounce_user
  end
  
  # (before-filter) ensures that the session belongs to an administrator
  def authenticated_as_admin
    authenticated_as_user
    return if performed?
    
    bounce_user unless current_user.admin?
  end
end
