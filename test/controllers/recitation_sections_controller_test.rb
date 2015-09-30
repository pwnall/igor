require 'test_helper'

class RecitationSectionsControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  describe 'authenticated as a non-course-editor' do
    before { set_session_current_user users(:dexter) }

    describe 'all actions' do
      it 'forbids access to the page' do
        post :autoassign, params: { course_id: courses(:main).to_param }
        assert_response :forbidden
      end
    end
  end

  describe 'POST #autoassign' do
    before { set_session_current_user users(:main_staff) }

    it 'queues the partition construction as a background job' do
      assert_enqueued_jobs 1 do
        post :autoassign, params: { course_id: courses(:main).to_param }
      end
    end

    it 'emails the current user with a link to the finished partition view' do
      assert_difference 'ActionMailer::Base.deliveries.size' do
        perform_enqueued_jobs do
          post :autoassign, params: { course_id: courses(:main).to_param }
        end
      end
    end

    it 'creates a new partition' do
      assert_difference 'RecitationPartition.count' do
        perform_enqueued_jobs do
          post :autoassign, params: { course_id: courses(:main).to_param }
        end
      end
    end

    it 'redirects to the recitation sections index' do
      post :autoassign, params: { course_id: courses(:main).to_param }
      assert_redirected_to recitation_sections_url
    end
  end
end
