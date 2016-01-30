require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  before do
    @user = users(:dexter)
    set_session_current_user users(:dexter)
  end

  it "must get index" do
    set_session_current_user users(:admin)
    get :index
    assert_response :success
  end

  it "must get new" do
    set_session_current_user nil
    get :new
    assert_response :success
  end

  it "must show user" do
    get :show, params: { id: @user }
    assert_response :success
  end

  it "must not show user when logged out" do
    set_session_current_user nil
    get :show, params: { id: @user }
    assert_response :forbidden
  end

  it "must get edit" do
    get :edit, params: { id: @user }
    assert_response :success, response.body
  end

  it "must not get edit when logged out" do
    set_session_current_user nil
    get :edit, params: { id: @user }
    assert_response :forbidden
  end


  describe "POST /users" do
    before do
      set_session_current_user nil

      @registration_params = {
          email: 'dexter2@mit.edu', password: 'sekret',
          password_confirmation: 'sekret',
          profile_attributes: {
            name: 'Dexter the Great',
            nickname: 'Dexter',
            university: 'Massachusetts Institute of Technology',
            department: 'Electrical Eng & Computer Sci',
            year: 'G'
          } }
    end

    it "should register a user with valid params" do
      assert_difference 'User.count' do
        post :create, params: { user: @registration_params }
      end

      assert_redirected_to new_session_url
    end

    it "should re-render the new template with invalid params" do
      assert_no_difference 'User.count' do
        @registration_params[:profile_attributes] = { }
        post :create, params: { user: {
            email: 'dexter2@mit.edu', password: 'sekret',
            password_confirmation: 'typo' } }
      end
    end
  end

  it "must update a user" do
    put :update, params: { id: @user, user: {
        profile_attributes: { id: 0xbadbeef, nickname: 'Dexterius' } } }
    assert_response :redirect, response.body
    assert_redirected_to user_path(@user)
    assert_equal 'Dexterius', @user.profile.nickname
  end

  it "must not update when logged out" do
    set_session_current_user nil
    put :update, params: { id: @user, user: {
        profile_attributes: { id: 0xbadbeef, nickname: 'Dexterius' } } }
    assert_response :forbidden
    assert_not_equal 'Dexterius', @user.reload.profile.nickname
  end

  it "must destroy a user" do
    set_session_current_user users(:admin)
    assert_difference 'User.count', -1 do
      delete :destroy, params: { id: @user }
    end
    assert_response :redirect, response.body
    assert_redirected_to users_path
  end

  it "must not destroy when logged out" do
    set_session_current_user nil
    assert_no_difference 'User.count' do
      delete :destroy, params: { id: @user }
    end
    assert_response :forbidden
  end
end
