require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def setup
    @user = users :admin
    @password = 'password'  
  end
  
  def test_index_without_user 
    get :index
    assert_template :index
  end
  
  def test_index_with_valid_user
    get :index, {}, { :user_id => @user.id }
    assert_redirected_to :controller => :welcome, :action => :home
  end
  
  def test_login_good_user_and_password
    post :create, :user => { :name => @user.name, :password => @password }
    assert_redirected_to :controller => :welcome, :action => :home
    assert_equal @user.id, session[:user_id]
  end
  
  def test_bad_password
    post :create, :user => { :name => @user.name, :password => 'wrong' }
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id],
                 "User entered incorrect password but session was still set"
  end
  
  def test_bad_user
    post :create, :user => { :name => "wrong", :password => 'wrong' }
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id],
                 "Nonexistent user but session was still set"
  end
  
  def test_logout
    delete :destroy, :id => 0
    assert_redirected_to :action => :index
    assert_equal nil, session[:user_id],
                 "Session not set to nil even though user logged out"
    assert_equal "You have been logged out", flash[:notice]
  end  
end
