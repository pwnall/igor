require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.
  include ActiveJob::TestHelper

  before do
    @deliverable = deliverables :assessment_writeup
    @submission = submissions :dexter_code
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

  describe 'authenticated as a registered student' do
    let(:user) { users(:dexter) }
    before { set_session_current_user user }

    describe 'POST #create' do
      it 'queues the submission for analysis' do
        assert_enqueued_jobs 1 do
          post :create, params: create_params
        end
      end

      describe 'no submissions from the current user for the deliverable' do
        before do
          @deliverable.submissions.where(subject: user).destroy_all
        end

        it 'creates a submission with no collaborators' do
          assert_difference 'Submission.count' do
            post :create, params: create_params
          end
          assert_empty Submission.last.collaborators
        end

        it "redirects to the submission's deliverable tab" do
          post :create, params: create_params
          assert_redirected_to @controller.deliverable_panel_url(@deliverable)
        end
      end

      describe 'current user has previously submitted for the deliverable' do
        before do
          @previous_submission = Submission.where(subject: user,
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

        it "redirects to the submission's deliverable tab" do
          post :create, params: create_params
          assert_redirected_to @controller.deliverable_panel_url(@deliverable)
        end
      end

      describe 'the assignment is locked' do
        before do
          @submission.assignment.update! released_at: 1.year.from_now,
              due_at: 2.years.from_now
        end

        it 'does not queue anything for analysis' do
          assert_enqueued_jobs 0 do
            post :create, params: create_params
          end
        end

        it 'does not create any submission' do
          assert_no_difference 'Submission.count' do
            post :create, params: create_params
          end
        end

        it 'bounces the user' do
          post :create, params: create_params
          assert_response :forbidden
        end
      end

      describe 'the assignment is not scheduled' do
        before do
          @submission.assignment.update! scheduled: false
        end

        it 'does not queue anything for analysis' do
          assert_enqueued_jobs 0 do
            post :create, params: create_params
          end
        end

        it 'does not create any submission' do
          assert_no_difference 'Submission.count' do
            post :create, params: create_params
          end
        end

        it 'bounces the user' do
          post :create, params: create_params
          assert_response :forbidden
        end
      end
    end

    describe 'POST #promote' do
      describe 'the due date for the student has not passed' do
        before do
          assert_equal false, @submission.assignment.deadline_passed_for?(user)
        end

        it 'queues the submission for analysis' do
          assert_enqueued_jobs 1 do
            post :promote, params: member_params
          end
        end

        it 'selects the submission for grading' do
          assert_equal false, @submission.selected_for_grading?
          post :promote, params: member_params
          assert_equal true, @submission.selected_for_grading?
        end

        it "redirects to the submission's deliverable tab" do
          post :promote, params: member_params
          assert_redirected_to @controller.deliverable_panel_url(
              @submission.deliverable)
        end
      end

      describe 'the due date for the student has passed' do
        before do
          assignment = @submission.assignment
          assignment.update! released_at: nil, due_at: 10.years.ago
          assignment.extensions.where(user: user).destroy_all
          assert_equal true, assignment.reload.deadline_passed_for?(user)
        end

        it 'forbids the student from changing their submission' do
          post :promote, params: member_params
          assert_response :forbidden
        end
      end

      describe 'the assignment is locked' do
        before do
          @submission.assignment.update! released_at: 1.year.from_now,
              due_at: 2.years.from_now
        end

        it 'forbids the student from changing their submission' do
          post :promote, params: member_params
          assert_response :forbidden
        end
      end

      describe 'the assignment is not scheduled' do
        before do
          @submission.assignment.update! scheduled: false
        end

        it 'forbids the student from changing their submission' do
          post :promote, params: member_params
          assert_response :forbidden
        end
      end
    end
  end

  describe 'authenticated as a course editor' do
    let(:user) { users(:main_staff) }
    before { set_session_current_user user }

    describe 'POST #promote' do
      describe 'the main submission deadline has passed' do
        before do
          @submission.assignment.update! released_at: nil, due_at: 10.years.ago
        end

        it 'queues the submission for analysis' do
          assert_enqueued_jobs 1 do
            post :promote, params: member_params
          end
        end

        it 'selects the submission for grading' do
          assert_equal false, @submission.selected_for_grading?
          post :promote, params: member_params
          assert_equal true, @submission.selected_for_grading?
        end

        it "redirects to the submission's deliverable tab" do
          post :promote, params: member_params
          assert_redirected_to @controller.deliverable_panel_url(
              @submission.deliverable)
        end
      end
    end

    describe 'POST #reanalyze' do
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
  end

  describe 'XHR GET #info' do
  end
end
