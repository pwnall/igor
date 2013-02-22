require 'test_helper'

class SurveysControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:dexter)
  end
  
  test "admin should get index" do
    set_session_current_user users(:admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:surveys)
  end
  
  test "user should not get index" do
    set_session_current_user users(:dexter)
    get :index
    assert_response 403
  end
  
  test "visitor should not get index" do
    get :index
    assert_response 403
  end  

  test "admin should get new" do
    set_session_current_user users(:admin)
    get :new
    assert_response :success
  end

  test "admin should create survey" do
    set_session_current_user users(:admin)
    assert_difference('Survey.count') do
      post :create, { :survey => surveys(:psets).attributes }
    end

    assert_redirected_to edit_survey_path(assigns(:survey))
  end

  test "admin should show survey" do
    set_session_current_user users(:admin)
    get :show, { :id => surveys(:psets).to_param }
    assert_response :success
  end

  test "admin should get edit" do
    set_session_current_user users(:admin)
    get :edit, { :id => surveys(:psets).to_param }
    assert_response :success
  end

  test "admin should update survey" do
    set_session_current_user users(:admin)
    put :update, { :id => surveys(:psets).to_param,
                   :survey => surveys(:psets).attributes }
    assert_redirected_to survey_questions_path
  end

  test "admin should destroy survey" do
    set_session_current_user users(:admin)
    assert_difference('Survey.count', -1) do
      delete :destroy, { :id => surveys(:psets).to_param }
    end

    assert_redirected_to surveys_path
  end
end
