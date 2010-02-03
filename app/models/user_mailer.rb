class UserMailer < ActionMailer::Base
  def email_confirmation(token, token_url)
    @subject    = 'alg.csail.mit.edu email confirmation token'
    @body       = { :token => token, :token_url => token_url}
    @recipients = token.user.email
    @from       = '6.006-tas@mit.edu'
    @sent_on    = Time.now
    @headers    = {}
  end
  
  def recovery_email(token, token_url)
    @subject    = 'alg.csail.mit.edu login name/password recovery'
    @body       = { :token => token, :token_url => token_url}
    @recipients = token.user.email
    @from       = '6.006-tas@mit.edu'
    @sent_on    = Time.now
    @headers    = {}
  end
end
