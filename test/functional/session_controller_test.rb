require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end
  
  test "user home page" do
    set_session_current_user @user
    get :show
    
    assert_equal @user, assigns(:user)
    assert_select 'a', 'Log out'
  end
  
  test "user logged in JSON request" do
    set_session_current_user @user
    get :show, :format => 'json'
    
    assert_equal @user.exuid,
        ActiveSupport::JSON.decode(response.body)['user']['exuid']
  end
  
  test "application welcome page" do
    get :show
    
    assert_equal User.count, assigns(:user_count)
    assert_select 'a', 'Log in'
  end

  test "user not logged in with JSON request" do
    get :show, :format => 'json'

    assert_equal({}, ActiveSupport::JSON.decode(response.body))
  end
end
