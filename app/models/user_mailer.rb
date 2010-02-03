class UserMailer < ActionMailer::Base
  def email_confirmation(token, token_url, server_url)
    @subject    = "#{Course.main.number} server email confirmation token"
    @body       = { :token => token, :token_url => token_url,
                    :course => Course.main,
                    :server_url => server_url }
    @recipients = token.user.email
    @from       = Course.main.number + '-tas@mit.edu'
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def recovery_email(token, token_url, server_url)
    @subject    = "#{Course.main.number} server login name/password recovery"
    @body       = { :token => token, :token_url => token_url,
                    :course => Course.main,
                    :server_url => server_url }
    @recipients = token.user.email
    @from       = Course.main.number + '-tas@mit.edu'
    @sent_on    = Time.now
    @headers    = {}
  end
end
