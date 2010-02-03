require 'test_helper'


class UserMailerTest < ActionMailer::TestCase
  tests UserMailer
  fixtures :tokens
  
  def test_email_confirmation
    @expected.subject = 'UserMailer#email_confirmation'
    @expected.body    = read_fixture('email_confirmation')
    @expected.date    = Time.now

    token = tokens(:inactive_email_confirmation)
    UserMailer.create_email_confirmation(token, 'http://token').parts.
               each do |part|
      assert_match 'costan+lurker@mit.edu', part.body
      assert_match 'http://token', part.body
    end
  end
end
