require 'test_helper'

class SurveyQuestionsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:dexter)
  end
  
  test "admin should get index" do
    set_session_current_user users(:admin)
    get :index
    assert_response :success
    assert_template :index
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
    assert_template :new
    assert_response :success
  end

  test "admin should create survey_question" do
    set_session_current_user users(:admin)
    assert_difference('SurveyQuestion.count') do
      post :create, { :survey_question => survey_questions(:hours).attributes }
    end
    assert_redirected_to survey_questions_path
  end

  test "admin should show survey_question" do
    set_session_current_user users(:admin)
    get :show, { :id => survey_questions(:hours).to_param }
    assert_response :success
  end

  test "admin should get edit" do
    set_session_current_user users(:admin)
    get :edit, { :id => survey_questions(:hours).to_param }
     
    assert_response :success
  end

  test "admin should update survey_question" do
    set_session_current_user users(:admin)
    put :update, { :id => survey_questions(:hours).to_param,
                   :survey_question => survey_questions(:hours).attributes }
    assert_redirected_to survey_questions_path
  end

  test "admin should destroy survey_question" do
    set_session_current_user users(:admin)
    assert_difference('SurveyQuestion.count', -1) do
      delete :destroy, { :id => survey_questions(:hours).to_param }
    end

    assert_redirected_to survey_questions_path
  end
end
