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

  test "admin should create prerequisite" do
    session[:user_id] = users(:admin).id
    assert_difference('Prerequisite.count') do
      post :create, :prerequisite => { :course_number => '6.042',
          :waiver_question => 'What is your math experience?' }
    end

    assert_redirected_to prerequisites_path
  end
  
  test "user should not create prerequisite" do
    session[:user_id] = users(:dexter).id
    assert_no_difference 'Prerequisite.count' do
      post :create, :prerequisite => { :course_number => '6.042',
          :waiver_question => 'What is your math experience?' }
    end
  end

  test "should show prerequisite" do
    get :show, :id => prerequisites(:math).to_param, :format => 'xml'
    assert_response :success
  end  

  test "should get edit" do
    session[:user_id] = users(:admin).id    
    get :edit, :id => prerequisites(:math).to_param
    assert_response :success
  end

  test "admin should update prerequisite" do
    session[:user_id] = users(:admin).id    
    put :update, :id => prerequisites(:math).to_param, 
                 :prerequisite => { :course_number => '6.042J' }
    assert_redirected_to prerequisites_path
    assert_equal '6.042J', prerequisites(:math).reload.course_number
  end

  test "user should not update prerequisite" do
    session[:user_id] = users(:dexter).id    
    put :update, :id => prerequisites(:math).to_param, 
                 :prerequisite => { :course_number => '6.042J' }
    assert_equal '6.042', prerequisites(:math).reload.course_number
  end

  test "should destroy prerequisite" do
    session[:user_id] = users(:admin).id
    assert_difference('Prerequisite.count', -1) do
      delete :destroy, :id => prerequisites(:math).to_param
    end

    assert_redirected_to prerequisites_path
  end

  test "user should not destroy prerequisite" do
    session[:user_id] = users(:dexter).id
    assert_no_difference 'Prerequisite.count' do
      delete :destroy, :id => prerequisites(:math).to_param
    end
  end
end
