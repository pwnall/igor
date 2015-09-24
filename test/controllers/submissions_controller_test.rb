require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.
  include ActiveJob::TestHelper

  before do
    @deliverable = deliverables :assessment_writeup
    @submission = submissions :dexter_assessment
  end

  let(:create_params) do
    file = fixture_file_upload 'files/submission/small.pdf', 'application/pdf',
                               :binary
    { course_id: courses(:main).to_param, submission: {
      deliverable_id: @deliverable.to_param, db_file_attributes: { f: file } } }
  end
  let(:member_params) do
    { course_id: courses(:main).to_param, id: @submission.to_param }
  end

  describe 'POST #create' do
    before { set_session_current_user users(:dexter) }

    it 'queues the submission for analysis' do
      assert_enqueued_jobs 1 do
        post :create, params: create_params
      end
    end

    describe 'no submissions from the current user for the deliverable' do
      before do
        @deliverable.submissions.where(subject: users(:dexter)).destroy_all
      end

      it 'creates a submission with no collaborators' do
        assert_difference 'Submission.count' do
          post :create, params: create_params
        end
        assert_empty Submission.last.collaborators
      end

      it "redirects to the deliverable's assignment page" do
        post :create, params: create_params
        assert_redirected_to assignment_url(@deliverable.assignment,
            course_id: @deliverable.course)
      end
    end

    describe 'current user has previously submitted for the deliverable' do
      before do
        @previous_submission = Submission.where(subject: users(:dexter),
            deliverable: @deliverable).last
        assert_not_nil @previous_submission
      end

      it 'reuses the collaborators from the previous submission' do
        assert_difference 'Submission.count' do
          post :create, params: create_params
        end

        latest_collaborators = Submission.last.collaborators
        assert_equal [users(:deedee)].to_set, latest_collaborators.to_set
        assert_equal latest_collaborators.to_set,
            @previous_submission.collaborators.to_set
      end

      it "redirects to the deliverable's assignment page" do
        post :create, params: create_params
        assert_redirected_to assignment_url(@deliverable.assignment,
            course_id: @deliverable.course)
      end
    end
  end

  describe 'POST #reanalyze' do
    before { set_session_current_user users(:main_staff) }

    it 'queues the submission for analysis' do
      assert_enqueued_jobs 1 do
        post :reanalyze, params: member_params
      end
    end

    it "redirects to the submission's analysis page" do
      post :reanalyze, params: member_params
      assert_redirected_to analysis_url(@submission.analysis,
          course_id: @submission.course)
    end
  end

  describe 'XHR GET #info' do
  end
end
