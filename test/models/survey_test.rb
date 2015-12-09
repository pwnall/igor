require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  before do
    @due_at = Time.current.round 0  # Remove sub-second information.
    @survey = Survey.new name: 'Prerequisites', released: false,
        course: courses(:main), due_at: @due_at
  end

  let(:survey) { surveys(:project) }
  let(:current_hour) { Time.current.beginning_of_hour }

  it 'validates the setup survey' do
    assert @survey.valid?, @survey.errors.full_messages
  end

  it 'requires a name' do
    @survey.name = nil
    assert @survey.invalid?
  end

  it 'rejects lengthy names' do
    @survey.name = 's' * 129
    assert @survey.invalid?
  end

  it 'forbids multiple surveys in the same course from sharing names' do
    @survey.name = survey.name
    assert @survey.invalid?
  end

  it 'requires a released status' do
    @survey.released = nil
    assert @survey.invalid?
  end

  it 'requires a course' do
    @survey.course = nil
    assert @survey.invalid?
  end

  it 'destroys dependent records' do
    assert_not_empty survey.questions
    assert_not_empty survey.responses

    survey.destroy

    assert_empty survey.questions.reload
    assert_empty survey.responses.reload
  end

  describe '#answered_by?' do
    it 'is true if the given user has responded to this survey' do
      assert_not_nil SurveyResponse.find_by user: users(:dexter), survey: survey
      assert_equal true, survey.answered_by?(users(:dexter))
    end

    it 'is false if the user does not have a response to the survey' do
      assert_nil SurveyResponse.find_by user: users(:deedee), survey: survey
      assert_equal false, survey.answered_by?(users(:deedee))
    end

    it 'is false if the user is nil' do
      assert_equal false, survey.answered_by?(nil)
    end
  end

  describe '#can_submit?' do
    describe 'survey has been released' do
      before { survey.update! released: true }

      it 'lets registered students and course/site admins view the survey' do
        assert_equal true, survey.can_submit?(users(:dexter))
        assert_equal false, survey.can_submit?(users(:inactive))
        assert_equal false, survey.can_submit?(users(:robot))
        assert_equal false, survey.can_submit?(users(:main_grader))
        assert_equal true, survey.can_submit?(users(:main_staff))
        assert_equal true, survey.can_submit?(users(:admin))
        assert_equal false, survey.can_submit?(nil)
      end
    end

    describe 'survey has not been released' do
      before { survey.update! released: false }

      it 'lets only course/site admins view the survey' do
        assert_equal false, survey.can_submit?(users(:dexter))
        assert_equal false, survey.can_submit?(users(:inactive))
        assert_equal false, survey.can_submit?(users(:robot))
        assert_equal false, survey.can_submit?(users(:main_grader))
        assert_equal true, survey.can_submit?(users(:main_staff))
        assert_equal true, survey.can_submit?(users(:admin))
        assert_equal false, survey.can_submit?(nil)
      end
    end
  end

  describe '#can_edit?' do
    it 'returns true for course/site admins only' do
      assert_equal false, survey.can_edit?(users(:dexter))
      assert_equal false, survey.can_edit?(users(:robot))
      assert_equal false, survey.can_edit?(users(:main_grader))
      assert_equal true, survey.can_edit?(users(:main_staff))
      assert_equal true, survey.can_edit?(users(:admin))
      assert_equal false, survey.can_edit?(nil)
    end
  end

  describe '#can_delete?' do
    describe 'survey has been released' do
      before { survey.update! released: true }

      describe 'students have already responded' do
        it 'lets only a site admin delete the survey' do
          assert_not_empty survey.responses

          assert_equal false, survey.can_delete?(users(:dexter))
          assert_equal false, survey.can_delete?(users(:robot))
          assert_equal false, survey.can_delete?(users(:main_grader))
          assert_equal false, survey.can_delete?(users(:main_staff))
          assert_equal true, survey.can_delete?(users(:admin))
          assert_equal false, survey.can_delete?(nil)
        end
      end

      describe 'no responses to the survey yet' do
        it 'lets only course/site admins delete the survey' do
          survey.responses.destroy_all

          assert_equal false, survey.can_delete?(users(:dexter))
          assert_equal false, survey.can_delete?(users(:robot))
          assert_equal false, survey.can_delete?(users(:main_grader))
          assert_equal true, survey.can_delete?(users(:main_staff))
          assert_equal true, survey.can_delete?(users(:admin))
          assert_equal false, survey.can_delete?(nil)
        end
      end
    end

    describe 'survey has not been released' do
      before { survey.update! released: false }

      it 'lets only course/site admins delete the survey' do
        assert_equal false, survey.can_delete?(users(:dexter))
        assert_equal false, survey.can_delete?(users(:robot))
        assert_equal false, survey.can_delete?(users(:main_grader))
        assert_equal true, survey.can_delete?(users(:main_staff))
        assert_equal true, survey.can_delete?(users(:admin))
        assert_equal false, survey.can_delete?(nil)
      end
    end
  end

  describe 'HasDeadline concern' do
    it 'requires a deadline' do
      @survey.deadline = nil
      assert @survey.invalid?
    end

    it 'destroys dependent records' do
      assert_not_nil survey.deadline

      survey.destroy

      assert_nil Deadline.find_by(subject: survey)
    end

    it 'saves the associated deadline through the parent' do
      new_time = @due_at + 1.day
      params = { deadline_attributes: { due_at: new_time } }
      @survey.update! params

      assert_equal new_time, @survey.reload.due_at
    end

    describe 'by_deadline scope' do
      it 'sorts the surveys by ascending deadline, then by name' do
        golden = surveys(:lab, :ps1, :project)
        actual = courses(:main).surveys.by_deadline
        assert_equal golden, actual, actual.map(&:name)
      end
    end

    describe 'with_upcoming_deadline scope' do
      it 'returns surveys whose deadlines have not passed' do
        golden = [surveys(:lab)]
        actual = courses(:main).surveys.with_upcoming_deadline
        assert_equal golden.to_set, actual.to_set, actual.map(&:name)
      end
    end

    describe '.with_upcoming_extension_for' do
      it 'returns surveys for which the user has an upcoming extension' do
        golden = surveys(:project, :lab)
        actual = courses(:main).surveys.
            with_upcoming_extension_for users(:dexter)
        assert_equal golden.to_set, actual.to_set, actual.map(&:name)
      end
    end

    describe 'past_due scope' do
      it 'returns surveys whose deadlines have passed' do
        golden = surveys(:ps1, :project)
        actual = courses(:main).surveys.past_due
        assert_equal golden.to_set, actual.to_set, actual.map(&:name)
      end
    end

    describe '.upcoming_for' do
      it 'returns released surveys the student can complete' do
        golden = [surveys(:lab)]
        actual = courses(:main).surveys.upcoming_for users(:dexter)
        assert_equal golden.to_set, actual.to_set, actual.map(&:name)
      end
    end

    describe '.default_due_at' do
      it 'returns the current hour' do
        assert_equal current_hour, Survey.default_due_at
      end
    end

    describe '#default_due_at' do
      it 'returns the current hour' do
        assert_equal current_hour, survey.default_due_at
      end
    end
  end
end
