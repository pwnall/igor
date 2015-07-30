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
    it 'reuses the collaborators from the previous submission' do
      previous_submission = Submission.where(subject: users(:dexter),
          deliverable: @deliverable).last

      assert_difference 'Submission.count' do
        post :create, params: { course_id: @params[:course_id],
            submission: @params[:submission] }
      end

      latest_collaborators = Submission.last.collaborators

      assert_equal [users(:deedee)].to_set, latest_collaborators.to_set
      assert_equal latest_collaborators.to_set,
          previous_submission.collaborators.to_set
    end
  end
end
