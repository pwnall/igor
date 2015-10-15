# Preview all emails at http://localhost:3000/rails/mailers/session_mailer
class SessionMailerPreview < ActionMailer::Preview
  def email_verification
    user = User.last
    SessionMailer.email_verification_email(
        Tokens::EmailVerification.random_for(user.email_credential),
        'http://test.host/')
  end

  def reset_password
    user = User.last
    SessionMailer.reset_password_email user.email,
        Tokens::PasswordReset.random_for(user),
        'http://test.host/'
  end
end
