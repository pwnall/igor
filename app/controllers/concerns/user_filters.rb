module UserFilters
  # (before-action) ensures that the session belongs to a registered user
  def authenticated_as_user
    return bounce_user if current_user.nil?
    # Inactive user.
    set_session_current_user nil
    bounce_user
  end

  # (before-action) ensures that the session belongs to an administrator
  def authenticated_as_admin
    authenticated_as_user
    return if performed?

    bounce_user unless current_user.admin?
  end
end
