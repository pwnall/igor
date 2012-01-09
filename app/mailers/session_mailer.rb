class SessionMailer < ActionMailer::Base
  include Authpwn::SessionMailer

  # The subject line in a password reset e-mail.
  def reset_password_subject(token, root_url)
    "Password reset for #{Course.main.number} server at #{root_url}"
  end
  
  # The sender e-mail address for a password reset e-mail.
  def reset_password_from(token, root_url)
    # You must replace the e-mail address below.
    "#{Course.main.number} staff <#{Course.main.email}>"
  end

  # Add your extensions to the SessionMailer class here.  
end
