require 'test_helper'

class PrerequisitesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prerequisites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create prerequisite" do
    assert_difference('Prerequisite.count') do
      post :create, :prerequisite => { }
    end

    assert_redirected_to prerequisite_path(assigns(:prerequisite))
  end

  test "should show prerequisite" do
    get :show, :id => prerequisites(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => prerequisites(:one).to_param
    assert_response :success
  end

  test "should update prerequisite" do
    put :update, :id => prerequisites(:one).to_param, :prerequisite => { }
    assert_redirected_to prerequisite_path(assigns(:prerequisite))
  end

  test "should destroy prerequisite" do
    assert_difference('Prerequisite.count', -1) do
      delete :destroy, :id => prerequisites(:one).to_param
    end

    assert_redirected_to prerequisites_path
  end
end
