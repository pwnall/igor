require 'test_helper'

class TokenMailerTest < ActionMailer::TestCase
  def setup
    @root_path = 'http://test/'    
    @token_path = 'http://test/token'
  end
  test "account_confirmation" do    
    token = tokens :inactive_email_confirmation
    mail = TokenMailer.account_confirmation token, @token_path, @root_path
    mail.parts.each do |part|
      assert_match 'costan+lurker@mit.edu', part.body
      assert_match @token_path, part.body
    end
  end
end
