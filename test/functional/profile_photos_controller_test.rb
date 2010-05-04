require 'test_helper'

class ProfilePhotosControllerTest < ActionController::TestCase
  setup do
    @profile_photo = profile_photos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profile_photos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile_photo" do
    assert_difference('ProfilePhoto.count') do
      post :create, :profile_photo => @profile_photo.attributes
    end

    assert_redirected_to profile_photo_path(assigns(:profile_photo))
  end

  test "should show profile_photo" do
    get :show, :id => @profile_photo.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @profile_photo.to_param
    assert_response :success
  end

  test "should update profile_photo" do
    put :update, :id => @profile_photo.to_param, :profile_photo => @profile_photo.attributes
    assert_redirected_to profile_photo_path(assigns(:profile_photo))
  end

  test "should destroy profile_photo" do
    assert_difference('ProfilePhoto.count', -1) do
      delete :destroy, :id => @profile_photo.to_param
    end

    assert_redirected_to profile_photos_path
  end
end
