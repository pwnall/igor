module UserFilters
  # (before-filter) ensures that the session belongs to a registered user
  def authenticated_as_user
    puts 'inside user auth'
    return bounce_user if current_user.nil?
    puts 'past bounce (cu.nil == false)'
    return true if current_user.email_credential.verified?
    puts 'past email ver. bad.'
    # Inactive user.
    set_session_current_user nil
    bounce_user
  end

  # (before-filter) ensures that the session belongs to an administrator
  def authenticated_as_admin
    authenticated_as_user
    return if performed?

    bounce_user unless current_user.admin?
  end
end
