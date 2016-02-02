require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  let(:create_params) do
    { user: { email: 'new_user@mit.edu', password: 'sekret',
      password_confirmation: 'sekret', profile_attributes: { name: 'New User',
      nickname: 'Noob', university: 'MIT', department: 'EECS', year: '1' } } }
  end
  let(:member_params) do
    { id: @user.to_param, user: { profile_attributes: { name: 'New',
      id: @user.profile.to_param } } }
  end

  describe 'unauthenticated user' do
    before { set_session_current_user nil }

    describe 'GET #index' do
      it 'forbids access to the page' do
        get :index
        assert_response :forbidden
      end
    end

    describe 'GET #new' do
      it 'renders the new user account form' do
        get :new
        assert_response :success
        assert_select 'section.register'
      end
    end

    describe 'GET #show' do
      it 'forbids access to any profile page' do
        get :show, params: { id: users(:dexter) }
        assert_response :forbidden

        get :show, params: { id: users(:main_staff) }
        assert_response :forbidden

        get :show, params: { id: users(:admin) }
        assert_response :forbidden
      end
    end

    describe 'GET #edit' do
      it 'forbids access to any profile edit form' do
        get :edit, params: { id: users(:dexter) }
        assert_response :forbidden

        get :edit, params: { id: users(:main_staff) }
        assert_response :forbidden

        get :edit, params: { id: users(:admin) }
        assert_response :forbidden
      end
    end

    describe 'POST #create' do
      describe 'user entered valid parameters' do
        it 'creates a new user' do
          assert_difference 'User.count' do
            post :create, params: create_params
          end
        end

        it 'automatically grants admin privileges to the first user' do
          Role.delete_all
          User.destroy_all
          assert_equal 0, User.count
          post :create, params: create_params
          assert_equal true, User.last.admin?
        end

        it 'does not grant admin privileges to users other than the first' do
          assert_operator 0, :<, User.count
          post :create, params: create_params
          assert_equal false, User.last.admin?
        end

        describe 'an SmtpServer has been configured' do
          before { assert_operator 0, :<, SmtpServer.count }

          it 'leaves the user e-mail in an unverified state' do
            post :create, params: create_params
            assert_equal false, User.last.email_credential.verified?
          end

          it 'redirects to the login page' do
            post :create, params: create_params
            assert_redirected_to new_session_url
          end
        end

        describe 'no SmtpServer has been configured' do
          before { SmtpServer.destroy_all }

          it 'automatically verifies the user e-mail' do
            post :create, params: create_params
            assert_equal true, User.last.email_credential.verified?
          end

          it 'redirects to the login page' do
            post :create, params: create_params
            assert_redirected_to new_session_url
          end
        end
      end

      describe 'user entered invalid parameters' do
        before { create_params[:user][:password_confirmation] = 'typo' }

        it 'does not create a new user' do
          assert_no_difference 'User.count' do
            post :create, params: create_params
          end
        end

        it 're-renders the new user form' do
          post :create, params: create_params
          assert_response :success
          assert_select 'section.signup'
        end
      end
    end

    describe 'PATCH #update' do
      it 'forbids the user from editing any profile' do
        @user = users(:dexter)
        original_name = @user.name
        patch :update, params: member_params
        assert_equal original_name, @user.reload.name
        assert_response :forbidden
      end
    end

    describe 'DELETE #destroy' do
      it 'forbids the user from deleting any profile' do
        @user = users(:dexter)
        assert_no_difference 'User.count' do
          delete :destroy, params: { id: @user }
        end
        assert_response :forbidden
      end
    end
  end

  describe 'authenticated as a registered student' do
    before do
      @user = users(:dexter)
      set_session_current_user @user
    end

    describe 'GET #index' do
      it 'forbids access to the page' do
        get :index
        assert_response :forbidden
      end
    end

    describe 'GET #show' do
      it 'can render your own profile page' do
        get :show, params: { id: @user }
        assert_response :success
      end

      it "can render your instructor's profile page" do
        get :show, params: { id: users(:main_staff) }
        assert_response :success
      end

      it "can render the site admin's profile page" do
        get :show, params: { id: users(:admin) }
        assert_response :success
      end

      it "can render a teammate's profile page" do
        teammate = users(:deedee)
        assert_equal true, @user.teammate_of?(teammate)
        get :show, params: { id: teammate }
        assert_response :success
      end

      it "cannot render a non-teammate classmate's profile page" do
        restricted_user = users(:mandark)
        assert_equal false, @user.teammate_of?(restricted_user)
        get :show, params: { id: restricted_user }
        assert_response :forbidden
      end
    end

    describe 'GET #edit' do
      it 'can render your own profile edit form' do
        get :edit, params: { id: @user }
        assert_response :success
        assert_select 'form.edit_user'
      end

      it "cannot render an instructor's profile edit form" do
        get :edit, params: { id: users(:main_staff) }
        assert_response :forbidden
      end

      it "cannot render a site admin's profile edit form" do
        get :edit, params: { id: users(:admin) }
        assert_response :forbidden
      end
    end

    describe 'PATCH #update' do
      describe 'user entered valid parameters' do
        it 'can update your own profile' do
          assert_equal 'Dexter Boy Genius', @user.name
          patch :update, params: member_params
          assert_equal 'New', @user.reload.name
        end

        it "cannot update a fellow student's profile" do
          @user = users(:deedee)
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
          assert_response :forbidden
        end

        it "cannot update an instructor's profile" do
          @user = users(:main_staff)
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
          assert_response :forbidden
        end

        it "cannot update a site admin's profile" do
          @user = users(:admin)
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
          assert_response :forbidden
        end

        it "redirects to your profile page when successful" do
          patch :update, params: member_params
          assert_redirected_to @user
        end
      end

      describe 'user entered invalid parameters' do
        before { member_params[:user][:profile_attributes][:name] = '' }

        it 'does not change any records' do
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
        end

        it 're-renders the profile edit form' do
          patch :update, params: member_params
          assert_response :success
          assert_select 'form.edit_user'
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'cannot destroy your own account' do
        assert_no_difference 'User.count' do
          delete :destroy, params: { id: @user }
        end
        assert_response :forbidden
      end

      { deedee: 'a fellow student', main_staff: 'an instructor',
          admin: 'a site admin', robot: 'a robot' }.each do |user, role|
        it "cannot delete #{role}'s account" do
          assert_no_difference 'User.count' do
            delete :destroy, params: { id: users(user) }
          end
          assert_response :forbidden
        end
      end
    end
  end

  describe 'authenticated as a course editor' do
    before do
      @user = users(:main_staff)
      set_session_current_user @user
    end

    describe 'GET #index' do
      it 'forbids access to the page' do
        get :index
        assert_response :forbidden
      end
    end

    describe 'GET #show' do
      it 'can render your own profile page' do
        get :show, params: { id: @user }
        assert_response :success
      end

      it "can render a fellow instructor's profile page" do
        get :show, params: { id: users(:main_staff_2) }
        assert_response :success
      end

      it "can render the site admin's profile page" do
        get :show, params: { id: users(:admin) }
        assert_response :success
      end
    end

    describe 'GET #edit' do
      it 'can render your own profile edit form' do
        get :edit, params: { id: @user }
        assert_response :success
        assert_select 'form.edit_user'
      end

      it "cannot render a student's profile edit form" do
        get :edit, params: { id: users(:dexter) }
        assert_response :forbidden
      end

      it "cannot render a site admin's profile edit form" do
        get :edit, params: { id: users(:admin) }
        assert_response :forbidden
      end
    end

    describe 'PATCH #update' do
      describe 'user entered valid parameters' do
        it 'can update your own profile' do
          assert_equal 'Main Staff', @user.name
          patch :update, params: member_params
          assert_equal 'New', @user.reload.name
        end

        it "cannot update a student's profile" do
          @user = users(:dexter)
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
          assert_response :forbidden
        end

        it "cannot update a fellow instructor's profile" do
          @user = users(:main_staff_2)
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
          assert_response :forbidden
        end

        it "cannot update a site admin's profile" do
          @user = users(:admin)
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
          assert_response :forbidden
        end

        it "redirects to your profile page when successful" do
          patch :update, params: member_params
          assert_redirected_to @user
        end
      end

      describe 'user entered invalid parameters' do
        before { member_params[:user][:profile_attributes][:name] = '' }

        it 'does not change any records' do
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
        end

        it 're-renders the profile edit form' do
          patch :update, params: member_params
          assert_response :success
          assert_select 'form.edit_user'
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'cannot destroy your own account' do
        assert_no_difference 'User.count' do
          delete :destroy, params: { id: @user }
        end
        assert_response :forbidden
      end

      { dexter: 'a student', main_staff_2: 'a fellow instructor',
          admin: 'a site admin', robot: 'a robot' }.each do |user, role|
        it "cannot delete #{role}'s account" do
          assert_no_difference 'User.count' do
            delete :destroy, params: { id: users(user) }
          end
          assert_response :forbidden
        end
      end
    end
  end

  describe 'authenticated as a site admin' do
    before do
      @user = users(:admin)
      set_session_current_user @user
    end

    describe 'GET #index' do
      it 'renders the full list of site users' do
        get :index
        assert_response :success
        assert_select 'table#site-users'
      end
    end

    describe 'GET #show' do
      it "can render anyone's profile page" do
        get :show, params: { id: @user }
        assert_response :success

        get :show, params: { id: users(:main_staff) }
        assert_response :success

        get :show, params: { id: users(:dexter) }
        assert_response :success
      end
    end

    describe 'GET #edit' do
      it "can render anyone's profile edit form" do
        get :edit, params: { id: @user }
        assert_response :success
        assert_select 'form.edit_user'

        get :edit, params: { id: users(:main_staff) }
        assert_response :success
        assert_select 'form.edit_user'

        get :edit, params: { id: users(:dexter) }
        assert_response :success
        assert_select 'form.edit_user'
      end
    end

    describe 'PATCH #update' do
      describe 'user entered valid parameters' do
        it 'can update your own profile' do
          assert_equal 'Admin', @user.name
          patch :update, params: member_params
          assert_equal 'New', @user.reload.name
        end

        it "can update a student's profile" do
          @user = users(:dexter)
          original_name = @user.name
          patch :update, params: member_params
          assert_equal 'New', @user.reload.name
        end

        it "can update an instructor's profile" do
          @user = users(:main_staff_2)
          original_name = @user.name
          patch :update, params: member_params
          assert_equal 'New', @user.reload.name
        end

        it "redirects to the user's profile page" do
          @user = users(:dexter)
          patch :update, params: member_params
          assert_redirected_to @user
        end
      end

      describe 'user entered invalid parameters' do
        before { member_params[:user][:profile_attributes][:name] = '' }

        it 'does not change any records' do
          original_name = @user.name
          patch :update, params: member_params
          assert_equal original_name, @user.reload.name
        end

        it 're-renders the profile edit form' do
          patch :update, params: member_params
          assert_response :success
          assert_select 'form.edit_user'
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'cannot destroy your own account even if another admin exists' do
        assert_operator 1, :<, Role.where(name: 'admin').count
        assert_no_difference 'User.count' do
          delete :destroy, params: { id: @user }
        end
        assert_response :forbidden
      end

      { dexter: 'a student', main_staff: 'an instructor',
          admin_2: 'a fellow site admin' }.each do |user, role|
        it "can delete #{role}'s account" do
          assert_difference 'User.count', -1 do
            delete :destroy, params: { id: users(user) }
          end
          assert_redirected_to users_url
        end
      end

      it "cannot destroy the site robot's account" do
        @user = users(:robot)
        assert_no_difference 'User.count' do
          delete :destroy, params: { id: @user }
        end
        assert_response :forbidden
      end
    end
  end
end
