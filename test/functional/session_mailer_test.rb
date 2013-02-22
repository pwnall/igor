require 'test_helper'

class SessionMailerTest < ActionMailer::TestCase
  setup do
    @reset_email = credentials(:jane_email).email
    @reset_token = credentials(:jane_password_token)
    @verification_token = credentials(:john_email_token)
    @verification_email = credentials(:john_email).email
    @root_url = 'hxxp://test.host/'
  end
  
  ## TODO
  #  ActionView::Template::Error: The single-table inheritance mechanism failed to locate the subclass: 'Tokens::Base'. This error is raised because the column 'type' is reserved for storing the class in case of inheritance. Please rename this column if you didn't intend it to be used for storing the inheritance class or overwrite Credential.inheritance_column to use another column for that information.
  

  #test 'email verification email' do
  #  email = SessionMailer.email_verification_email(@verification_token,
  #                                                 @root_url).deliver
  #  assert !ActionMailer::Base.deliveries.empty?
  #  
  #  assert_equal "6.006 e-mail verification", email.subject
  #  assert_equal ['vic.tor@costan.us'], email.from
  #  assert_equal '"6.006 staff" <vic.tor@costan.us>', email['from'].to_s
  #  assert_equal [@verification_email], email.to
  #  assert_match @verification_token.code, email.encoded
  #  assert_match @root_url, email.encoded
  #end  

  #test 'password reset email' do
  #  email = SessionMailer.reset_password_email(@reset_email, @reset_token,
  #                                             @root_url).deliver
  #  assert !ActionMailer::Base.deliveries.empty?
  #  
  #  assert_equal 'test.host password reset', email.subject
  #  assert_equal ['admin@test.host'], email.from
  #  assert_equal '"test.host staff" <admin@test.host>', email['from'].to_s
  #  assert_equal [@reset_email], email.to
  #  assert_match @reset_token.code, email.encoded
  #  assert_match @root_url, email.encoded
  #end  
end
