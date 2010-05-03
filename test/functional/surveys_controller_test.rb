require 'test_helper'

class SurveysControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:dexter)
  end
  
  test "admin should get index" do
    get :index, {}, { :user_id => @admin.id }
    assert_response :success
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
    assert_response :success
  end

  test "admin should create survey" do
    assert_difference('Survey.count') do
      post :create, { :survey => surveys(:psets).attributes },
           { :user_id => @admin.id }      
    end

    assert_redirected_to edit_survey_path(assigns(:survey))
  end

  test "admin should show survey" do
    get :show, { :id => surveys(:psets).to_param }, { :user_id => @admin.id }
    assert_response :success
  end

  test "admin should get edit" do
    get :edit, { :id => surveys(:psets).to_param }, { :user_id => @admin.id }
    assert_response :success
  end

  test "admin should update survey" do
    put :update, { :id => surveys(:psets).to_param,
                   :survey => surveys(:psets).attributes },
        { :user_id => @admin.id }
    assert_redirected_to survey_questions_path
  end

  test "admin should destroy survey" do
    assert_difference('Survey.count', -1) do
      delete :destroy, { :id => surveys(:psets).to_param },
             { :user_id => @admin.id }
    end

    assert_redirected_to surveys_path
  end
end
