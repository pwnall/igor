class ActionDispatch::IntegrationTest
  # Log in as the given user.
  def log_in_as(user)
    password = (user == users(:dexter)) ? 'pa55w0rd' : 'password'

    visit '/'
    fill_in 'session_email', with: user.email
    fill_in 'session_password', with: password
    click_button 'Log in'
    assert_equal '/6.006', current_path
  end
end
