require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def setup
    @user = users :admin
    @password = 'password'  
  end
  
  test "when logged out renders generic news screen" do 
    get :index
    assert_response :success
    assert_template :index

    assert_select '#header .account-panel .user-name', false,
                  'Not logged in, should not get any name in user panel'
  end
  
  test "when admin logged in, index renders home page" do
    get :index, {}, { :user_id => @user.id }
    assert_response :success
    assert_template :index
    
    assert_select '#header .account-panel .user-name', /admin/,
                  'User panel should show admin'    
  end

  test "when regular user logged in, index renders home page" do
    get :index, {}, { :user_id => users(:dexter).id }
    assert_response :success
    assert_template :index
    
    assert_select '#header .account-panel .user-name', /dexter/,
                  'User panel should show dexter'    
  end

  test "smoke test for home page of inactive user" do
    get :index, {}, { :user_id => users(:inactive).id }
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

    assert_template :index
    assert_equal @user.name, assigns(:login).name,
                 "User input (name) not retained"
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
