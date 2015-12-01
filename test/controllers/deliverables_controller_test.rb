require 'test_helper'

class DeliverablesControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  before do
    @deliverable = deliverables(:assessment_writeup)
  end

  let(:member_params) do
    { course_id: courses(:main).to_param, id: @deliverable.to_param }
  end

  describe 'authenticated as a registered student' do
    before { set_session_current_user users(:dexter) }

    describe 'all actions' do
      it 'forbids access to the page' do
        post :reanalyze, params: member_params
        assert_response :forbidden

        get :submission_dashboard, params: member_params, xhr: true
        assert_response :forbidden
      end
    end
  end

  describe 'authenticated as a staff member' do
    before { set_session_current_user users(:main_staff) }

    describe 'POST #reanalyze' do
      it 'queues all submissions for the deliverable for analysis' do
        assert_enqueued_jobs 3 do
          post :reanalyze, params: member_params
        end
      end

      it 'redirects to the assignment dashboard' do
        post :reanalyze, params: member_params
        assert_redirected_to dashboard_assignment_url(@deliverable.assignment,
            course_id: @deliverable.course)
      end
    end

    describe 'XHR GET #submission_dashboard' do
      it 'renders the list of all submission analyses for the deliverable' do
        get :submission_dashboard, params: member_params, xhr: true
        assert_response :success
        assert_select 'ol.submission-list li.submission-list-entry', 3
      end
    end
  end
end
