require 'test_helper'

class FeedbackQuestionSetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feedback_question_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feedback_question_set" do
    assert_difference('FeedbackQuestionSet.count') do
      post :create, :feedback_question_set => feedback_question_sets(:one).attributes
    end

    assert_redirected_to feedback_question_set_path(assigns(:feedback_question_set))
  end

  test "should show feedback_question_set" do
    get :show, :id => feedback_question_sets(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => feedback_question_sets(:one).to_param
    assert_response :success
  end

  test "should update feedback_question_set" do
    put :update, :id => feedback_question_sets(:one).to_param, :feedback_question_set => feedback_question_sets(:one).attributes
    assert_redirected_to feedback_question_set_path(assigns(:feedback_question_set))
  end

  test "should destroy feedback_question_set" do
    assert_difference('FeedbackQuestionSet.count', -1) do
      delete :destroy, :id => feedback_question_sets(:one).to_param
    end

    assert_redirected_to feedback_question_sets_path
  end
end
