require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    @user = users(:dexter)    
  end
  
  test "show does not work without login" do
    get :show, :id => @user.profile.id
    assert_redirected_to root_path
  end
  
  test "show does not reveal other person's contact info" do
    get :show, { :id => @user.profile.id }, { :user_id => users(:solo).id }
    assert_response :success
    assert_template :show
    assert_select 'dl.profile dt' do |elements|
      assert !elements.any? { |e| e.match /phone/i },
             "Dexter's phone number should not be revealed to other users"      
    end
    
    assert_equal assigns(:profile), @user.profile
  end
    
  test "show reveals everything for own profile" do
    get :show, { :id => @user.profile.id }, { :user_id => @user.id }
    check_profile_reveals_everything    
  end

  test "show reveals everything for admins" do
    get :show, { :id => @user.profile.id }, { :user_id => users(:admin).id }
    check_profile_reveals_everything
  end
  
  def check_profile_reveals_everything
    assert_response :success
    assert_template :show
    assert_equal assigns(:profile), @user.profile
    assert_select 'dl.profile dt' do |elements|
      assert elements.any? { |e| e.match /phone/i },
             "Dexter's profile should have a phone number"
    end
  end  
end
