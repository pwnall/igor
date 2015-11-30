require 'test_helper'

class GradeTest < ActiveSupport::TestCase
  before do
    @grade = Grade.new subject: users(:dexter), grader: users(:admin),
        metric: assignment_metrics(:ps1_p1), course: courses(:main), score: 3.0
  end

  let(:grade) { grades(:dexter_assessment_overall) }

  it 'validates the setup grade' do
    assert @grade.valid?
  end

  describe 'AssignmentFeedback concern' do
    it 'requires a metric' do
      @grade.metric = nil
      assert @grade.invalid?
    end

    it 'forbids a student from having multiple grades for a single metric' do
      @grade.metric = assignment_metrics(:assessment_overall)
      assert @grade.invalid?
    end

    it 'requires the grader to have permission to grade the metric' do
      authorized_graders = users(:robot, :main_grader, :main_staff, :admin)
      authorized_graders.each do |grader|
        @grade.grader = grader
        assert @grade.valid?
      end

      @grade.grader = users(:dexter)
      assert @grade.invalid?
    end

    it 'requires a course' do
      @grade.course = nil
      assert @grade.invalid?
    end

    it "requires that the course matches the metric's course" do
      @grade.course = courses(:not_main)
      assert @grade.invalid?
    end

    it 'requires a grader' do
      @grade.grader = nil
      assert @grade.invalid?
    end

    it 'requires a subject' do
      @grade.subject = nil
      assert @grade.invalid?
    end

    describe ':subject is a student' do
      it 'requires the student to be registered for the course' do
        assert_not_includes users(:inactive).registered_courses, @grade.course
        @grade.subject = users(:inactive)
        assert @grade.invalid?
      end
    end

    describe ':subject is a team' do
      it "requires the team's partition to belong to the course" do
        assert_not_equal courses(:main), teams(:not_main_lab).course
        @grade.subject = teams(:not_main_lab)
        assert @grade.invalid?
      end
    end
  end

  it 'requires a numeric score' do
    invalid_scores = ['string', '1string']
    invalid_scores.each do |score|
      @grade.score = score
      assert @grade.invalid?
    end

    valid_scores = [1, 1.1111, '1', '1.1']
    valid_scores.each do |score|
      @grade.score = score
      assert @grade.valid?
    end
  end

  describe '#weighted_score' do
    it 'returns the weighted score' do
      assert_equal 15, @grade.weighted_score
    end
  end

  describe '#users' do
    describe 'individual student grades' do
      it 'returns an array containing the student' do
        assert_equal [users(:dexter)], grade.users
      end
    end

    describe 'team grades' do
      it 'returns an array containing the team members' do
        assert_equal [users(:dexter)].to_set,
            grades(:awesome_ps1_p1).users.to_set
      end
    end
  end

  describe '#act_on_user_input' do
    describe 'the grade is a new record' do
      describe 'the score text is blank' do
        it 'destroys the grade and returns true' do
          assert_no_difference 'Grade.count' do
            result = @grade.act_on_user_input('')
            assert_equal true, result
          end
          assert_equal true, @grade.destroyed?
        end
      end

      describe 'the score text is not blank' do
        it 'saves the grade, using the given score' do
          assert_equal 3.0, @grade.score

          assert_difference 'Grade.count' do
            result = @grade.act_on_user_input('4')
            assert_equal true, result
          end
          assert_equal 4.0, @grade.reload.score
        end

        describe 'the grade is invalid' do
          before { @grade.grader = users(:dexter) }

          it 'returns false' do
            assert_equal 3.0, @grade.score

            assert_no_difference 'Grade.count' do
              result = @grade.act_on_user_input('8')
              assert_equal false, result
            end
          end

          it 'keeps the new score' do
            assert_equal 3.0, @grade.score
            @grade.act_on_user_input('8')
            assert_equal 8.0, @grade.score
          end
        end
      end
    end

    describe 'the grade is an existing record' do
      describe 'the score text is blank' do
        it 'destroys the grade and returns true' do
          assert_difference 'Grade.count', -1 do
            result = grade.act_on_user_input('')
            assert_equal true, result
          end
        end
      end

      describe 'the score text is not blank' do
        it 'updates the grade score' do
          assert_equal 70.0, grade.score
          result = grade.act_on_user_input('4')

          assert_equal 4.0, grade.reload.score
          assert_equal true, result
        end

        it 'returns false if the update failed' do
          assert_equal 70.0, grade.score
          result = grade.act_on_user_input('invalid input')

          assert_equal 70.0, grade.reload.score
          assert_equal false, result
        end
      end
    end
  end
end
