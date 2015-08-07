require 'test_helper'

class GradeCommentTest < ActiveSupport::TestCase
  before do
    @comment = GradeComment.new subject: users(:dexter), grader: users(:admin),
        metric: assignment_metrics(:ps1_p1), course: courses(:main),
        text: 'Nice work!'
  end

  let(:comment) { grade_comments(:dexter_assessment_overall) }

  it 'validates the setup grade comment' do
    assert @comment.valid?
  end

  describe 'AssignmentFeedback concern' do
    it 'requires a metric' do
      @comment.metric = nil
      assert @comment.invalid?
    end

    it 'forbids a student from having multiple comments for a single metric' do
      @comment.metric = assignment_metrics(:assessment_overall)
      assert @comment.invalid?
    end

    it 'requires the grader to have permission to grade the metric' do
      authorized_graders = users(:robot, :main_grader, :main_staff, :admin)
      authorized_graders.each do |grader|
        @comment.grader = grader
        assert @comment.valid?
      end

      @comment.grader = users(:dexter)
      assert @comment.invalid?
    end

    it 'requires a course' do
      @comment.course = nil
      assert @comment.invalid?
    end

    it "requires that the course matches the metric's course" do
      @comment.course = courses(:not_main)
      assert @comment.invalid?
    end

    it 'requires a subject' do
      @comment.subject = nil
      assert @comment.invalid?
    end

    it 'requires a grader' do
      @comment.grader = nil
      assert @comment.invalid?
    end
  end

  it 'requires not-blank text' do
    @comment.text = nil
    assert @comment.invalid?

    @comment.text = ''
    assert @comment.invalid?
  end

  it 'rejects lengthy comments' do
    @comment.text = 'a' * (4.kilobytes + 1)
    assert @comment.invalid?
  end

  describe '#act_on_user_input' do
    describe 'the comment is a new record' do
      describe 'the comment text is blank' do
        it 'destroys the comment and returns true' do
          assert_no_difference 'GradeComment.count' do
            result = @comment.act_on_user_input ''
            assert_equal true, result
          end
          assert_equal true, @comment.destroyed?
        end
      end

      describe 'the comment text is not blank' do
        it 'saves the comment, using the given comment text' do
          assert_equal 'Nice work!', @comment.text

          assert_difference 'GradeComment.count' do
            result = @comment.act_on_user_input 'New comment'
            assert_equal true, result
          end
          assert_equal 'New comment', @comment.reload.text
        end

        describe 'the comment is invalid' do
          before { @comment.grader = users(:dexter) }

          it 'returns false' do
            assert_equal 'Nice work!', @comment.text

            assert_no_difference 'GradeComment.count' do
              result = @comment.act_on_user_input 'Comment grader is invalid.'
              assert_equal false, result
            end
          end

          it 'keeps the new text' do
            assert_equal 'Nice work!', @comment.text
            @comment.act_on_user_input 'Comment grader is invalid.'
            assert_equal 'Comment grader is invalid.', @comment.text
          end
        end
      end
    end

    describe 'the comment is an existing record' do
      describe 'the comment text is blank' do
        it 'destroys the comment and returns true' do
          assert_difference 'GradeComment.count', -1 do
            result = comment.act_on_user_input ''
            assert_equal true, result
          end
        end
      end

      describe 'the comment text is not blank' do
        it 'updates the comment text' do
          assert_equal 'Good job.', comment.text
          result = comment.act_on_user_input 'New comment'

          assert_equal 'New comment', comment.reload.text
          assert_equal true, result
        end

        it 'returns false if the update failed' do
          assert_equal 'Good job.', comment.text
          comment.grader = users(:dexter)
          result = comment.act_on_user_input 'Comment grader is invalid.'

          assert_equal 'Good job.', comment.reload.text
          assert_equal false, result
        end
      end
    end
  end
end
