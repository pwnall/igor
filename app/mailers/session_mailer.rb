class SessionMailer < ActionMailer::Base
  include Authpwn::SessionMailer

  def reset_password_subject(token, server_hostname)
    "#{Course.main.number} password reset"
  end
  
  # The sender e-mail address for a password reset e-mail.
  def reset_password_from(token, root_url)
    "#{Course.main.number} staff <#{Course.main.email}>"
  end

  # Add your extensions to the SessionMailer class here.  
end
