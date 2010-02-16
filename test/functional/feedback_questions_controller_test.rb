require 'test_helper'

class FeedbackQuestionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feedback_questions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feedback_question" do
    assert_difference('FeedbackQuestion.count') do
      post :create, :feedback_question => feedback_questions(:one).attributes
    end

    assert_redirected_to feedback_question_path(assigns(:feedback_question))
  end

  test "should show feedback_question" do
    get :show, :id => feedback_questions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => feedback_questions(:one).to_param
    assert_response :success
  end

  test "should update feedback_question" do
    put :update, :id => feedback_questions(:one).to_param, :feedback_question => feedback_questions(:one).attributes
    assert_redirected_to feedback_question_path(assigns(:feedback_question))
  end

  test "should destroy feedback_question" do
    assert_difference('FeedbackQuestion.count', -1) do
      delete :destroy, :id => feedback_questions(:one).to_param
    end

    assert_redirected_to feedback_questions_path
  end
end
