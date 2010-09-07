require 'test_helper'

class TokensControllerTest < ActionController::TestCase
  def test_dispatch_with_spend
    @controller.expects(:charge).with(:amount => 100).once.returns(true)
    
    assert_difference 'Token.count', -1 do
      get :spend, :token => tokens(:fictional_charge).token
    end    
    assert_redirected_to sessions_path
  end
  
  def test_dispatch_without_spend
    @controller.expects(:charge).with(:amount => 100).once.returns(false)
    
    assert_no_difference 'Token.count' do
      get :spend, :token => tokens(:fictional_charge).token
    end
    assert_redirected_to sessions_path
  end
  
  def test_invalid_token
    assert_no_difference 'Token.count' do
      get :spend, :token => 'z' * 16
    end
    assert_redirected_to sessions_path    
    assert_operator /invalid token/i, :=~, flash[:error], 'Error flash not set'
  end

  def test_email_confirmation
    assert !users(:inactive).active, 'User was active when test started'

    assert_difference 'Token.count', -1 do
      get :spend, :token => tokens(:inactive_email_confirmation).token
    end
    assert_redirected_to sessions_path
    
    assert users(:inactive).reload.active, 'User still inactive'
  end
  
  def test_password_reset
    dexter = users(:dexter)
    password = 'pa55w0rd'
    assert User.authenticate(dexter.name, password),
           "Test case doesn't have Dexter's correct password"
    
    assert_difference 'Token.count', -1 do
      get :spend, :token => tokens(:dexter_password_reset).token      
    end
    assert_redirected_to edit_password_user_path(dexter)
    assert_equal dexter.id, session[:user_id], "Didn't log in once as dexter"
    
    assert !User.authenticate(dexter.name, password),
           "Dexter's password wasn't changed by the reset"
  end
end
