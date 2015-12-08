require 'test_helper'

class ActionItemTest < ActiveSupport::TestCase
  before do
    @course = courses(:main)
    @student = users(:dexter)
    @assignment = assignments(:assessment)
    @item = ActionItem.new @student, @assignment
  end

  it 'initializes the :subject correctly' do
    assert_equal @assignment, @item.subject
  end

  it 'initializes the due date correctly' do
    assert_equal @assignment.due_at_for(@student), @item.due_at
  end

  describe '.for' do
    describe 'the user is a student' do
      describe 'the current course is not nil' do
        it 'returns an ActionItem for each actionable (sub)task in the course,
            sorted soonest to latest due date (accounting for extensions),
            alphabetical name' do
          golden = [deliverables(:assessment_writeup),
                    deliverables(:assessment_code), surveys(:lab)].map(&:name)
          actual = ActionItem.for(@student, @course).map(&:description)
          assert_equal golden, actual
        end
      end

      describe 'the current course is nil' do
        it 'returns an ActionItem for each actionable (sub)task in taken
            courses, sorted latest to earliest due date (accounting for
            extensions), reverse alphabetical name' do
          golden = [deliverables(:assessment_writeup),
                    deliverables(:assessment_code), surveys(:lab)].map(&:name)
          actual = ActionItem.for(@student, nil).map(&:description)
          assert_equal golden, actual
        end
      end

      it 'records the correct due date for each action item' do
        golden = [assignments(:assessment), assignments(:assessment),
                  surveys(:lab)].map { |a| a.due_at_for @student }
        actual = ActionItem.for(@student, @course).map(&:due_at)
        assert_equal golden, actual
      end

      it 'records the correct submission state for each action item' do
        golden = [:ok, :rejected, :incomplete]
        actual = ActionItem.for(@student, @course).map(&:state)
        assert_equal golden, actual
      end
    end

    describe 'the user is nil' do
      it 'returns an empty array' do
        assert_empty ActionItem.for(nil, @course)
      end
    end
  end

  describe '.courses_for' do
    describe 'user is nil' do
      it 'returns an empty array' do
        assert_empty ActionItem.courses_for(nil)
      end
    end

    describe 'user is a site admin' do
      it 'returns all the courses' do
        golden = Course.all
        actual = ActionItem.courses_for users(:admin)
        assert_equal golden.to_set, actual.to_set, actual.map(&:number)
      end
    end

    describe 'user is a course staff member' do
      it 'returns all the courses taught/taken by the staff member' do
        golden = [courses(:main)]
        actual = ActionItem.courses_for users(:main_staff)
        assert_equal golden.to_set, actual.to_set, actual.map(&:number)
      end
    end

    describe 'user is a student' do
      it 'returns all the courses taught/taken by the student' do
        golden = [courses(:main)]
        actual = ActionItem.courses_for users(:dexter)
        assert_equal golden.to_set, actual.to_set, actual.map(&:number)
      end
    end
  end

  describe '.tasks_for' do
    describe 'user is nil' do
      it 'returns an empty array' do
        assert_empty ActionItem.tasks_for(nil, @course)
      end
    end

    describe 'course is nil, user is admin' do
      it 'returns actionable assignments/surveys for all courses, sorted soonest
          to latest deadline, alphabetical name' do
        golden = [assignments(:not_main_exam), assignments(:assessment),
                  surveys(:lab)]
        actual = ActionItem.tasks_for users(:admin), nil
        assert_equal golden, actual, actual.map(&:name)
      end
    end

    describe 'course is nil, user is staff member' do
      it 'returns actionable assignments/surveys for taught courses, sorted
          soonest to latest deadline, alphabetical name' do
        golden = [assignments(:assessment),surveys(:lab)]
        actual = ActionItem.tasks_for users(:main_staff), nil
        assert_equal golden, actual, actual.map(&:name)
      end
    end

    describe 'course is nil, user is student' do
      it 'returns actionable assignments/surveys for taken courses, sorted
          soonest to latest due date (accounting for extensions), alphabetical
          name' do
        golden = [assignments(:ps2), assignments(:assessment), surveys(:lab)]
        actual = ActionItem.tasks_for users(:dexter), nil
        assert_equal golden, actual, actual.map(&:name)
      end
    end

    describe 'course is not nil, user is student' do
      it 'returns actionable assignments/surveys for taken courses, sorted
          soonest to latest due date (accounting for extensions), alphabetical
          name' do
        golden = [assignments(:ps2), assignments(:assessment), surveys(:lab)]
        actual = ActionItem.tasks_for users(:dexter), courses(:main)
        assert_equal golden, actual, actual.map(&:name)
      end
    end
  end

  describe '.analysis_state_for' do
    describe 'the user has not submitted yet' do
      before do
        @deliverable = deliverables(:ps3_writeup)
        assert_empty @deliverable.submissions.where(subject: @student)
      end

      it 'returns :incomplete' do
        actual = ActionItem.analysis_state_for @student, @deliverable
        assert_equal :incomplete, actual
      end
    end

    describe 'the submission does not have an analysis' do
      before do
        @deliverable = deliverables(:project_writeup)
        submission = @deliverable.submission_for_grading @student
        assert_nil submission.analysis
      end

      it 'returns :incomplete' do
        actual = ActionItem.analysis_state_for @student, @deliverable
        assert_equal :incomplete, actual
      end
    end

    describe 'the analysis has not finished running' do
      before do
        @deliverable = deliverables(:ps1_writeup)
        submission = @deliverable.submission_for_grading @student
        assert_equal true, submission.analysis.status_will_change?
      end

      it 'returns :incomplete' do
        actual = ActionItem.analysis_state_for @student, @deliverable
        assert_equal :incomplete, actual
      end
    end

    describe 'the submission passed its analysis' do
      before do
        @deliverable = deliverables(:assessment_writeup)
        submission = @deliverable.submission_for_grading @student
        assert_equal true, submission.analysis.submission_ok?
      end

      it 'returns :ok' do
        actual = ActionItem.analysis_state_for @student, @deliverable
        assert_equal :ok, actual
      end
    end

    describe 'the submission failed its analysis' do
      before do
        @deliverable = deliverables(:assessment_code)
        submission = @deliverable.submission_for_grading @student
        assert_equal true, submission.analysis.submission_rejected?
      end

      it 'returns :ok' do
        actual = ActionItem.analysis_state_for @student, @deliverable
        assert_equal :rejected, actual
      end
    end
  end
end
