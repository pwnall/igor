class TokenMailer < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.token_mailer.account_confirmation.subject
  #
  def account_confirmation(token)
    @course = Course.main
    @token = token

    mail :from => "#{Course.main.number}-tas@mit.edu",
         :to => @token.user.email,
         :subject => "#{Course.main.number} server email confirmation token"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.token_mailer.password_recovery.subject
  #
  def password_recovery(token)
    @course = Course.main
    @token = token

    mail :from => "#{Course.main.number}-tas@mit.edu",
         :to => @token.user.email,
         :subject => "#{Course.main.number} server username/password recovery"
  end
end
