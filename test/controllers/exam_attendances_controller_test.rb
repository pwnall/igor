require 'test_helper'

class ExamAttendancesControllerTest < ActionController::TestCase
  let(:exam) { exams(:main_exam) }
  let(:open_session) { exam_sessions(:main_exam_under_capacity) }
  let(:full_session) { exam_sessions(:main_exam_full_capacity) }
  let(:check_in_params) do
    { course_id: courses(:main).to_param,
      exam_session_id: @exam_session.to_param }
  end
  let(:member_params) do
    { course_id: courses(:main).to_param, id: @attendance.to_param }
  end
  let(:all_attendances_params) do
    { course_id: courses(:main).to_param, exam_id: exam.to_param }
  end
  let(:session_attendances_params) do
    { course_id: courses(:main).to_param, exam_id: exam.to_param,
      exam_session_id: @exam_session.to_param }
  end

  describe 'authenticated as a student who has not checked in yet' do
    before do
      assert_nil users(:deedee).exam_attendances.find_by(exam: exam)
      set_session_current_user users(:deedee)
    end

    describe 'POST #create' do
      it 'checks the student into the given (available) exam session' do
        @exam_session = open_session
        assert_difference 'ExamAttendance.count' do
          post :create, params: check_in_params
        end
        new_attendance = ExamAttendance.last
        assert_equal users(:deedee), new_attendance.user
        assert_equal true, exam.requires_confirmation?
        assert_equal false, new_attendance.confirmed?
      end

      it 'redirects to the exam session panel in the student assignment view' do
        @exam_session = open_session
        post :create, params: check_in_params
        assert_redirected_to @controller.exam_session_panel_url(@exam_session)
      end

      it 'bounces the user if the session has reached capacity' do
        @exam_session = full_session
        assert_equal false, @exam_session.has_available_seats?
        post :create, params: check_in_params
        assert_response :forbidden
      end
    end

    describe 'all actions except POST #create' do
      it 'forbids access to the page' do
        get :index, params: all_attendances_params
        assert_response :forbidden

        @attendance = exam_attendances(:dexter_under_capacity)
        patch :update, params: member_params, xhr: true
        assert_response :forbidden
      end
    end
  end

  describe 'authenticated as a student who has already checked in' do
    before do
      assert_not_nil open_session.attendances.find_by(user: users(:dexter))
      set_session_current_user users(:dexter)
    end

    describe 'POST #create' do
      it 'bounces the user if they checked in to a different session' do
        @exam_session = full_session
        post :create, params: check_in_params
        assert_response :forbidden
      end

      it 'bounces the user if they checked in to the given session' do
        @exam_session = open_session
        post :create, params: check_in_params
        assert_response :forbidden
      end
    end
  end

  describe 'authenticated as a staff' do
    before { set_session_current_user users(:main_staff) }
    let(:selected_session_option) do
      'form select#exam_session_id > option[selected="selected"]'
    end

    describe 'GET #index' do
      describe 'pass the id of a specific exam session' do
        before { @exam_session = open_session }

        it 'selects the given session in the dropdown' do
          get :index, params: session_attendances_params
          assert_response :success
          assert_select selected_session_option do
            assert_select ":match('value', ?)", @exam_session.to_param
          end
        end

        it 'lists the attendances for the given session' do
          get :index, params: session_attendances_params
          assert_response :success
          assert_select 'tr[data-student-name]', @exam_session.attendances.count
        end
      end

      describe 'no exam session id passed' do
        it 'does not select a specific session in the dropdown' do
          get :index, params: all_attendances_params
          assert_response :success
          assert_select selected_session_option, false
        end

        it 'lists all the attendances for the given exam' do
          get :index, params: all_attendances_params
          assert_response :success
          assert_select 'tr[data-student-name]', exam.attendances.count
        end
      end
    end

    describe 'XHR PATCH #update' do
      describe 'the :confirmed parameter is true' do
        before { @attendance = exam_attendances(:solo_full_capacity) }
        let(:params) { member_params.merge attendance: { confirmed: true } }

        it "confirms a student's attendance" do
          assert_equal false, @attendance.confirmed?
          patch :update, params: params, xhr: true
          assert_equal true, @attendance.reload.confirmed?
        end

        it "renders the student's confirmation status as confirmed" do
          patch :update, params: params, xhr: true
          assert_select 'input#confirmed[type="checkbox"]' do
            assert_select '[checked="checked"]'
          end
        end
      end

      describe 'the :confirmed parameter is false' do
        before { @attendance = exam_attendances(:dexter_under_capacity) }
        let(:params) { member_params.merge attendance: { confirmed: false } }

        it "unconfirms a student's attendance" do
          assert_equal true, @attendance.confirmed?
          patch :update, params: params, xhr: true
          assert_equal false, @attendance.reload.confirmed?
        end

        it "renders the student's confirmation status as unconfirmed" do
          patch :update, params: params, xhr: true
          assert_select 'input#confirmed[type="checkbox"]' do
            assert_select '[checked="checked"]', false
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      before { @attendance = exam_attendances(:dexter_under_capacity) }

      it 'destroys the attendance, if it is unconfirmed' do
        @attendance.update! confirmed: false
        assert_difference 'ExamAttendance.count', -1 do
          delete :destroy, params: member_params
        end
      end

      it 'destroys the attendance, if it is confirmed' do
        @attendance.update! confirmed: true
        assert_difference 'ExamAttendance.count', -1 do
          delete :destroy, params: member_params
        end
      end

      it 'redirects to the exam session roster' do
        @exam_session = @attendance.exam_session
        delete :destroy, params: member_params
        assert_redirected_to exam_attendances_url(session_attendances_params)
      end
    end
  end
end
