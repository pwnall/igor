module UserFilters
  # (before-filter) extracts the logged in user from the session
  def extract_user_filter
    @current_user = session[:user_id] &&
                    User.where(:id => session[:user_id]).first
    if @current_user
      response.headers['X-Account-Management-Status'] =
          "active; name=\"#{current_user.real_name}\""
    else
      response.headers['X-Account-Management-Status'] = "none"
    end
  end
  
  # bounces the user to a safe page via redirect_to and returns +false+
  def bounce_user(*args)
    flash[:error] = args[0] unless args.length < 1    
    redirect_to root_path
    return false
  end
  
  # (before-filter) ensures that the session belongs to a registered user
  def authenticated_as_user    
    return bounce_user('Login required') if current_user.nil?
    return true if current_user.active
    
    # inactive user
    session[:user_id] = nil
    bounce_user("Your account is inactive (did you validate your #{current_user.email} e-mail?)")
  end
  
  # (before-filter) ensures that the session belongs to an administrator
  def authenticated_as_admin
    return false unless authenticated_as_user
    return true if current_user.admin
    
    # not an administrator
    bounce_user("You'd need to be a teacher for this. Your attempt has been logged.")
  end
end
