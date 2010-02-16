require 'test_helper'

class FeedbackAnswersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feedback_answers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feedback_answer" do
    assert_difference('FeedbackAnswer.count') do
      post :create, :feedback_answer => feedback_answers(:one).attributes
    end

    assert_redirected_to feedback_answer_path(assigns(:feedback_answer))
  end

  test "should show feedback_answer" do
    get :show, :id => feedback_answers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => feedback_answers(:one).to_param
    assert_response :success
  end

  test "should update feedback_answer" do
    put :update, :id => feedback_answers(:one).to_param, :feedback_answer => feedback_answers(:one).attributes
    assert_redirected_to feedback_answer_path(assigns(:feedback_answer))
  end

  test "should destroy feedback_answer" do
    assert_difference('FeedbackAnswer.count', -1) do
      delete :destroy, :id => feedback_answers(:one).to_param
    end

    assert_redirected_to feedback_answers_path
  end
end
