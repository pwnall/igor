require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.

  before do
    set_session_current_user users(:dexter)
    @deliverable = deliverables :assessment_writeup
    file = fixture_file_upload 'submission_files/small.pdf',
        'application/pdf', :binary
    @params = { course_id: courses(:main).to_param, submission: {
        deliverable_id: @deliverable.to_param,
        db_file_attributes: { f: file } } }
  end

  describe 'POST #create' do
    describe 'no submissions from the current user for the deliverable' do
      before do
        @deliverable.submissions.where(subject: users(:dexter)).destroy_all
      end

      it 'creates a submission with no collaborators' do
        assert_difference 'Submission.count' do
          post :create, params: { course_id: @params[:course_id],
              submission: @params[:submission] }
        end

        assert_empty Submission.last.collaborators
      end

      it "redirects to the deliverable's assignment page" do
        post :create, params: { course_id: @params[:course_id],
            submission: @params[:submission] }

        assert_redirected_to assignment_url(@deliverable.assignment,
            course_id: @deliverable.course)
      end
    end

    describe 'current user has previously submitted for the deliverable' do
      it 'reuses the collaborators from the previous submission' do
        previous_submission = Submission.where(subject: users(:dexter),
            deliverable: @deliverable).last
        assert_not_nil previous_submission

        assert_difference 'Submission.count' do
          post :create, params: { course_id: @params[:course_id],
              submission: @params[:submission] }
        end

        latest_collaborators = Submission.last.collaborators

        assert_equal [users(:deedee)].to_set, latest_collaborators.to_set
        assert_equal latest_collaborators.to_set,
            previous_submission.collaborators.to_set
      end

      it "redirects to the deliverable's assignment page" do
        post :create, params: { course_id: @params[:course_id],
            submission: @params[:submission] }

        assert_redirected_to assignment_url(@deliverable.assignment,
            course_id: @deliverable.course)
      end
    end
  end

  describe 'XHR GET #info' do
  end
end
