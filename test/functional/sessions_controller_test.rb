require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def setup
    @user = users :admin
    @password = 'password'  
  end
  
  test "when logged out index redirects to login screen" do 
    get :index
    assert_redirected_to new_session_path
  end
  
  test "when logged in index renders home page" do
    get :index, {}, { :user_id => @user.id }
    assert_response :success
    assert_template :index
  end
  
  test "login with good credentials" do
    post :create, :user => { :name => @user.name, :password => @password }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
  end
  
  test "login with wrong password" do
    post :create, :user => { :name => @user.name, :password => 'wrong' }
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id],
                 "User entered incorrect password but session was still set"
  end
  
  test "login with inexistent username" do
    post :create, :user => { :name => "wrong", :password => 'wrong' }
    assert_equal "Invalid user/password combination", flash[:error]
    assert_equal nil, session[:user_id],
                 "Nonexistent user but session was still set"
  end
  
  test "logout" do
    delete :destroy, :id => 0
    assert_redirected_to root_path
    assert_equal nil, session[:user_id],
                 "Session not set to nil even though user logged out"
    assert_equal "You have been logged out", flash[:notice]
  end  
end
