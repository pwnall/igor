require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  def setup
    @token = Token.new :action => 'confirm_email', :argument => nil
  end
  
  test "setup is valid" do
    assert @token.valid?, @token.errors.inspect
  end
  
  test "building off an account" do
    assert_difference 'Token.count' do
      users(:admin).tokens.create :action => 'confirm_email'
    end
  end  
end
