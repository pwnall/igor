require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  describe 'authenticated as a registered student' do
    before { set_session_current_user users(:dexter) }

    describe 'GET #index' do
      it 'renders all assignments with released grades/deliverables' do
        get :index, params: { course_id: courses(:main).to_param }
        assert_response :success
        assert_select 'section.assignment', 3
      end
    end
  end

  describe 'authenticated as a course editor' do
    before { set_session_current_user users(:main_staff) }

    describe 'GET #index' do
      it 'renders all assignments' do
        get :index, params: { course_id: courses(:main).to_param }
        assert_response :success
        assert_select 'section.assignment', 5
      end
    end
  end
end
