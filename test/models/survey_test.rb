require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  before do
    @survey = Survey.new name: 'Prerequisites', published: false,
        course: courses(:main), due_at: Time.current
  end

  let(:survey) { surveys(:project) }

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

  it 'requires a published status' do
    @survey.published = nil
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

  describe '#can_respond?' do
    describe 'survey has been published' do
      before { survey.update! published: true }

      it 'lets registered students and course/site admins view the survey' do
        assert_equal true, survey.can_respond?(users(:dexter))
        assert_equal false, survey.can_respond?(users(:inactive))
        assert_equal false, survey.can_respond?(users(:robot))
        assert_equal false, survey.can_respond?(users(:main_grader))
        assert_equal true, survey.can_respond?(users(:main_staff))
        assert_equal true, survey.can_respond?(users(:admin))
        assert_equal false, survey.can_respond?(nil)
      end
    end

    describe 'survey has not been published' do
      before { survey.update! published: false }

      it 'lets only course/site admins view the survey' do
        assert_equal false, survey.can_respond?(users(:dexter))
        assert_equal false, survey.can_respond?(users(:inactive))
        assert_equal false, survey.can_respond?(users(:robot))
        assert_equal false, survey.can_respond?(users(:main_grader))
        assert_equal true, survey.can_respond?(users(:main_staff))
        assert_equal true, survey.can_respond?(users(:admin))
        assert_equal false, survey.can_respond?(nil)
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
    describe 'survey has been published' do
      before { survey.update! published: true }

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

    describe 'survey has not been published' do
      before { survey.update! published: false }

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
end
