class TokenMailer < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.actionmailer.token_mailer.account_confirmation.subject
  #
  def account_confirmation(token, root_url, token_url)
    @course = Course.main
    @token, @root_url, @token_url = token, root_url, token_url

    mail :subject => "#{Course.main.number} server email confirmation token",
         :from => Course.main.email,
         :to => @token.user.email do |format|
      format.html  # token_mailer/account_confirmation.text.html.erb
      format.text  # token_mailer/account_confirmation.text.plain.erb
    end
  end
end
