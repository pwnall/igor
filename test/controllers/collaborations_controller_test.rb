require 'test_helper'

class CollaborationsControllerTest < ActionController::TestCase
  before do
    @submission = submissions(:dexter_assessment)
  end

  let(:non_collaborator) { users(:solo) }
  let(:create_params) do
    { course_id: courses(:main).to_param, submission_id: @submission.to_param,
      collaboration: { collaborator_email: non_collaborator.email } }
  end

  describe 'authenticated as a registered student' do
    let(:user) { users(:dexter) }
    before { set_session_current_user user }

    describe 'POST #create' do
      describe 'the due date for the student has not passed' do
        before do
          assert_equal false, @submission.assignment.deadline_passed_for?(user)
        end

        it 'adds a new collaboration to the submission' do
          assert_not_includes @submission.collaborators, non_collaborator
          assert_difference 'Collaboration.count' do
            post :create, params: create_params
          end
          assert_includes @submission.reload.collaborators, non_collaborator
        end

        it "redirects to the submission's deliverable tab" do
          post :create, params: create_params
          assert_redirected_to @controller.deliverable_panel_url(
              @submission.deliverable)
        end
      end

      describe 'the due date for the student has passed' do
        before do
          assignment = @submission.assignment
          assignment.update! published_at: nil, due_at: 10.years.ago
          assignment.extensions.where(user: user).destroy_all
          assert_equal true, assignment.reload.deadline_passed_for?(user)
        end

        it 'forbids the student from adding a new collaborator' do
          post :create, params: create_params
          assert_response :forbidden
        end
      end
    end
  end

  describe 'authenticated as a course editor' do
    let(:user) { users(:main_staff) }
    before { set_session_current_user user }

    describe 'POST #create' do
      describe 'the main submission deadline has passed' do
        before do
          @submission.assignment.update! published_at: nil, due_at: 10.years.ago
        end

        it 'adds a new collaboration to the submission' do
          assert_not_includes @submission.collaborators, non_collaborator
          assert_difference 'Collaboration.count' do
            post :create, params: create_params
          end
          assert_includes @submission.reload.collaborators, non_collaborator
        end

        it "redirects to the submission's deliverable tab" do
          post :create, params: create_params
          assert_redirected_to @controller.deliverable_panel_url(
              @submission.deliverable)
        end
      end
    end
  end
end
