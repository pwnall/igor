require 'test_helper'

class ExamSessionsControllerTest < ActionController::TestCase
  let(:exam) { exams(:main_exam) }
  let(:open_session) { exam_sessions(:main_exam_under_capacity) }
  let(:full_session) { exam_sessions(:main_exam_full_capacity) }
  let(:member_params) do
    { course_id: courses(:main).to_param, id: exam_session.to_param }
  end

  describe 'POST #check_in' do
    describe 'authenticated as a course editor' do
      before { set_session_current_user users(:main_staff) }
      let(:exam_session) { open_session }

      it 'bounces the user if they are not a student in the course' do
        post :check_in, params: member_params
        assert_response :forbidden
      end
    end

    describe 'authenticated as a student in a different course' do
      before { set_session_current_user users(:not_main_student) }
      let(:exam_session) { open_session }

      it 'bounces the student' do
        post :check_in, params: member_params
        assert_response :forbidden
      end
    end

    describe 'authenticated as a student who has not checked in to any session
        for this exam' do
      before do
        assert_nil exam.attendances.find_by(user: users(:deedee))
        set_session_current_user users(:deedee)
      end

      describe 'the desired session is at capacity' do
        let(:exam_session) { full_session }

        it 'bounces the student' do
          post :check_in, params: member_params
          assert_response :forbidden
        end
      end

      describe 'the desired session is under capacity' do
        let(:exam_session) { open_session }

        it 'checks the student in to the exam session' do
          assert_difference 'ExamAttendance.count' do
            post :check_in, params: member_params
          end
          new_attendance = ExamAttendance.last
          assert_equal users(:deedee), new_attendance.user
          assert_equal exam_session, new_attendance.exam_session
          assert_equal !exam.requires_confirmation?, new_attendance.confirmed?
        end

        it "redirects to the student view exam session tab" do
          post :check_in, params: member_params
          assert_redirected_to @controller.exam_session_panel_url(exam_session)
        end
      end
    end

    describe 'authenticated as a student who has already checked in to the
        desired exam session' do
      before do
        assert_includes open_session.attendances.map(&:user), users(:dexter)
        set_session_current_user users(:dexter)
      end
      let(:exam_session) { open_session }

      it 'bounces the student' do
        post :check_in, params: member_params
        assert_response :forbidden
      end
    end

    describe 'authenticated as a student who has already checked in to a
        different session for this exam' do
      before do
        assert_includes full_session.attendances.map(&:user), users(:solo)
        set_session_current_user users(:solo)
      end
      let(:exam_session) { open_session }

      it 'bounces the student' do
        post :check_in, params: member_params
        assert_response :forbidden
      end
    end
  end
end
