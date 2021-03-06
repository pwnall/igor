require 'test_helper'

class DeadlineExtensionsControllerTest < ActionController::TestCase
  let(:assignment) { assignments(:assessment) }
  let(:extension) { deadline_extensions(:assessment_dexter) }
  let(:collection_params) do
    { course_id: courses(:main).to_param, assignment_id: assignment.to_param }
  end
  before do
    @year_due = Time.current.year + 1
    @month_due = '04'
    @day_due = '02'
    @hour_due = '16'
  end
  let(:date_param) do
    { due_at: "#{@year_due}-#{@month_due}-#{@day_due}T#{@hour_due}:00:00" }
  end
  let(:create_params) do
    { course_id: courses(:main).to_param, assignment_id: assignment.to_param,
      deadline_extension: { user_exuid: users(:solo).to_param }.
      merge(date_param) }
  end
  let(:member_params) do
    { course_id: courses(:main).to_param, id: extension.to_param }
  end

  describe 'authenticated as a student' do
    before { set_session_current_user users(:dexter) }

    describe 'all actions' do
      it 'forbids access to the page' do
        get :index, params: collection_params
        assert_response :forbidden

        post :create, params: create_params
        assert_response :forbidden

        delete :destroy, params: member_params
        assert_response :forbidden
      end
    end
  end

  describe 'authenticated as a grader' do
    before { set_session_current_user users(:main_grader) }

    describe 'all actions' do
      it 'forbids access to the page' do
        get :index, params: collection_params
        assert_response :forbidden

        post :create, params: create_params
        assert_response :forbidden

        delete :destroy, params: member_params
        assert_response :forbidden
      end
    end
  end

  describe 'authenticated as a course editor' do
    before { set_session_current_user users(:main_staff) }

    let(:user_select) { 'select#deadline_extension_user_exuid' }

    describe 'GET #index' do
      it 'renders all extensions granted for the given assignment' do
        get :index, params: collection_params

        assert_response :success
        assert_select 'h2', /#{assignment.name}/
        assert_select 'tr.extension', 2
      end

      it 'lists all enrolled students without extensions for the given
          assignment' do
        get :index, params: collection_params

        assert_response :success
        # NOTE: You must use the :match pseudo-selector to use regex.
        assert_select "#{user_select} > option:match('value', ?)", /\d+/, 2
        assert_select "#{user_select} > option[value=?]", users(:solo).to_param
      end
    end

    describe 'POST #create' do
      describe 'submit a valid extension' do
        it 'creates a new extension' do
          assert_difference 'DeadlineExtension.count' do
            post :create, params: create_params
          end
          assert_equal users(:main_staff), DeadlineExtension.last.grantor
        end

        it "redirects to the assignment's extensions page" do
          post :create, params: create_params
          assert_redirected_to assignment_extensions_url(collection_params)
        end
      end

      describe 'submit an extension for a user with an extension already' do
        before do
          create_params[:deadline_extension][:user_exuid] =
              users(:dexter).to_param
        end

        it "does not change the user's existing extension" do
          extension = assignment.extensions.find_by user: users(:dexter)
          due_at = extension.due_at
          assert_no_difference 'DeadlineExtension.count' do
            post :create, params: create_params
          end
          assert_equal due_at, extension.reload.due_at
        end

        it 'renders the student selection field with an error message' do
          post :create, params: create_params
          assert_response :success
          assert_select 'select#deadline_extension_user_exuid.is-invalid-input'
          assert_select '.form-error.is-visible'
        end

        it 'renders the extensions index page with form fields preselected to
            the previous values' do
          post :create, params: create_params
          assert_response :success
          assert_select 'input[name="deadline_extension[due_at]"][value=?]',
                        date_param[:due_at]
          assert_select "#{user_select} > option[selected='selected']", false
        end
      end

      describe 'submit an extension with a date before the original deadline' do
        before { @year_due = Time.current.year - 1 }

        it 'renders the deadline field with a validation error' do
          post :create, params: create_params
          assert_response :success
          assert_select 'input#deadline_extension_due_at.is-invalid-input'
          assert_select '.form-error.is-visible'
        end

        it 'renders the extensions index page with form fields preselected to
            the previous values' do
          post :create, params: create_params
          assert_response :success
          assert_select 'input[name="deadline_extension[due_at]"][value=?]',
                        date_param[:due_at]
          assert_select "#{user_select} > option[selected='selected'][value=?]",
              users(:solo).to_param
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the extension' do
        assert_difference 'DeadlineExtension.count', -1 do
          delete :destroy, params: member_params
        end
      end

      it 'renders the extensions index page' do
        delete :destroy, params: member_params
        assert_redirected_to assignment_extensions_url(collection_params)
      end
    end
  end
end
