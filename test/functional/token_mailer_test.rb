require 'test_helper'

class TokenMailerTest < ActionMailer::TestCase
  test "account_confirmation" do    
    token = tokens :inactive_email_confirmation
    mail = TokenMailer.account_confirmation token
    mail.parts.each do |part|
      assert_match 'costan+lurker@mit.edu', part.body
      assert_match 'http://token', part.body
    end
  end
end
