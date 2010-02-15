require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  def setup
    @user = users(:dexter)    
  end
  
  test "my_own does not work without login" do
    get :my_own
    assert_redirected_to new_session_path
  end
  
  test "simple my_own" do
    get :my_own, {}, { :user_id => @user.id }
    assert_response :success
    assert_template 'new_edit'
    assert_equal assigns(:profile), @user.profile
  end
  
  test "my_own refuses to render another profile" do
    get :my_own, { :id => users(:admin).to_param }, { :user_id => @user.id }
    assert_response :success
    assert_equal assigns(:profile), @user.profile
  end
end
