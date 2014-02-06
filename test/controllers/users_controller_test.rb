require 'test_helper'

describe UsersController do
  fixtures :users

  before do
    @user = users(:dexter)
    set_session_current_user users(:dexter)
  end

  it "must get index" do
    set_session_current_user users(:admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  it "must get new" do
    set_session_current_user nil
    get :new
    assert_response :success
  end

  it "must show user" do
    get :show, id: @user
    assert_response :success
    assert_equal @user, assigns(:user)
  end

  it "must get edit" do
    get :edit, id: @user
    assert_response :success, response.body
    assert_equal @user, assigns(:user)
  end

  describe "POST /users" do
    before do
      set_session_current_user nil

      @registration_params = {
          email: 'dexter2@mit.edu', password: 'sekret',
          password_confirmation: 'sekret',
          profile_attributes: {
            athena_username: 'dexter2',
            name: 'Dexter the Great',
            nickname: 'Dexter',
            university: 'Massachusetts Institute of Technology',
            department: 'Electrical Eng & Computer Sci',
            year: 'G'
          } }
    end

    it "should register a user with valid params" do
      assert_difference 'User.count' do
        post :create, user: @registration_params
      end

      assert_redirected_to new_session_url
    end

    it "should re-render the new template with invalid params" do
      assert_no_difference 'User.count' do
        @registration_params[:profile_attributes] = { }
        post :create, user: {
            email: 'dexter2@mit.edu', password: 'sekret',
            password_confirmation: 'typo' }
      end
    end
  end

  it "must update a user" do
    put :update, id: @user.to_param, user: {
        profile_attributes: { nickname: 'Dexterius' } }
    assert_equal @user, assigns(:user)
    assert_response :redirect, response.body
    assert_redirected_to user_path(assigns(:user))
    assert_equal 'Dexterius', @user.profile.nickname
  end

  it "must destroy a user" do
    set_session_current_user users(:admin)
    assert_difference 'User.count', -1 do
      delete :destroy, id: @user
    end
    assert_response :redirect, response.body
    assert_redirected_to users_path
  end
end
