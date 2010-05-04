require 'test_helper'

class SurveyQuestionsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:dexter)
  end
  
  test "admin should get index" do
    get :index, {}, { :user_id => @admin.id }
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:surveys)
  end

  test "user should not get index" do
    get :index, {}, { :user_id => @user.id }
    assert_redirected_to root_path
  end
  
  test "visitor should not get index" do
    get :index
    assert_redirected_to root_path
  end

  test "admin should get new" do
    get :new, {}, { :user_id => @admin.id }
    assert_template :new
    assert_response :success
  end

  test "admin should create survey_question" do
    assert_difference('SurveyQuestion.count') do
      post :create, { :survey_question => survey_questions(:hours).attributes },
           { :user_id => @admin.id }
    end
    assert_redirected_to survey_questions_path
  end

  test "admin should show survey_question" do
    get :show, { :id => survey_questions(:hours).to_param },
        { :user_id => @admin.id }
    assert_response :success
  end

  test "admin should get edit" do
    get :edit, { :id => survey_questions(:hours).to_param },
        { :user_id => @admin.id }
     
    assert_response :success
  end

  test "admin should update survey_question" do
    put :update, { :id => survey_questions(:hours).to_param,
                   :survey_question => survey_questions(:hours).attributes },
        { :user_id => @admin.id }
    assert_redirected_to survey_questions_path
  end

  test "admin should destroy survey_question" do
    assert_difference('SurveyQuestion.count', -1) do
      delete :destroy, { :id => survey_questions(:hours).to_param },
             { :user_id => @admin.id }
    end

    assert_redirected_to survey_questions_path
  end
end
