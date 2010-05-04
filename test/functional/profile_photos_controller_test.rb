require 'test_helper'

class ProfilePhotosControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @profile_photo = profile_photos(:dexter)
    @profile = @profile_photo.profile
    @user = @profile.user
    @bits = fixture_file_upload 'profile_pics/costan.png','image/png'
  end

  test "admin should get index" do
    get :index, {}, { :user_id => @admin.id }
    assert_response :success
    assert_not_nil assigns(:profile_photos)
  end

  test "user should get new" do
    get :new, { :profile_id => @profile.id }, { :user_id => @user.id }
    assert_response :success
  end

  test "admin should create new profile_photo" do
    assert_difference('ProfilePhoto.count') do
      post :create, { :profile_photo => { :pic => @bits,
           :profile_id => profiles(:solo).id } }, { :user_id => @admin.id }
    end
    assert_redirected_to user_path(users(:solo))
  end

  test "user should overwrite existing profile_photo" do
    assert_no_difference('ProfilePhoto.count') do
      post :create, { :profile_photo => { :pic => @bits,
           :profile_id => @profile.id } }, { :user_id => @user.id }
    end
    assert_redirected_to user_path(@user)
  end

  test "should show profile_photo" do
    get :show, { :id => @profile_photo.to_param }, { :user_id => @user.id }
    assert_response :success
  end

  test "user should update profile_photo" do
    put :update, { :id => @profile_photo.to_param,
        :profile_photo => @profile_photo.attributes }, { :user_id => @user.id }
    assert_redirected_to user_path(@user)
  end

  test "admin should destroy profile_photo" do
    assert_difference('ProfilePhoto.count', -1) do
      delete :destroy, { :id => @profile_photo.to_param },
                       { :user_id => @admin.id }
    end
    assert_redirected_to user_path(@user)
  end
end
