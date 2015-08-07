require 'test_helper'

class GradeCommentsControllerTest < ActionController::TestCase
  describe 'authenticated as a registered student' do
    before { set_session_current_user users(:dexter) }

    describe 'XHR POST #create' do
      it 'forbids access to the page' do
        post :create, params: { course_id: courses(:main).to_param }, xhr: true
        assert_response :forbidden
      end
    end
  end

  describe 'authenticated as a grader' do
    before { set_session_current_user users(:admin) }

    describe 'XHR POST #create' do
      let(:student) { users(:dexter) }
      let(:metric) { assignment_metrics(:assessment_overall) }
      let(:params) do
        { course_id: courses(:main).to_param, comment: {
          subject_id: student.to_param, subject_type: 'User',
          metric_id: metric.to_param, text: 'New comment' } }
      end

      describe 'enter a new comment' do
        before do
          GradeComment.where(subject: student, metric: metric).destroy_all
        end

        it 'creates a new comment' do
          assert_difference 'GradeComment.count' do
            post :create, params: params, xhr: true
          end
          assert_equal 'New comment', GradeComment.last.text
        end

        it 'renders the new comment in the textarea' do
          post :create, params: params, xhr: true
          assert_response :success
          assert_select 'textarea#comment', 'New comment'
        end
      end

      describe 'change an existing comment' do
        it 'updates the text of the comment' do
          comment = GradeComment.find_by subject: student, metric: metric
          assert_equal 'Good job.', comment.text
          post :create, params: params, xhr: true

          assert_equal 'New comment', comment.reload.text
        end

        it 'renders the updated text in the textarea' do
          post :create, params: params, xhr: true
          assert_response :success
          assert_select 'textarea#comment', 'New comment'
        end
      end

      describe 'enter an invalid text value' do
        before { params[:comment][:text] = 'a' * (4.kilobytes + 1) }

        it 'does not change an existing comment' do
          comment = GradeComment.find_by subject: student, metric: metric
          assert_equal 'Good job.', comment.text

          assert_no_difference 'GradeComment.count' do
            post :create, params: params, xhr: true
          end
          assert_equal 'Good job.', comment.reload.text
        end

        it 'responds with a :not_acceptable header' do
          post :create, params: params, xhr: true
          assert_response :not_acceptable
        end
      end

      describe 'delete existing text' do
        before { params[:comment][:text] = '' }

        it 'destroys the comment' do
          assert_not_nil GradeComment.find_by(subject: student, metric: metric)
          assert_difference 'GradeComment.count', -1 do
            post :create, params: params, xhr: true
          end
        end

        it 'renders an empty textarea' do
          post :create, params: params, xhr: true

          assert_response :success
          assert_select 'textarea#comment', ''
        end
      end
    end
  end
end
