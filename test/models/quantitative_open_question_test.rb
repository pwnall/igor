require 'test_helper'

class QuantitativeOpenQuestionTest < ActiveSupport::TestCase
  before do
    @question = QuantitativeOpenQuestion.new survey: surveys(:ps1),
        prompt: 'How many collaborators did you have?', allows_comments: false,
        step_size: 0.05
  end

  let(:question) { survey_questions(:hours) }
  let(:any_user) { User.new }

  it 'validates the setup question' do
    assert @question.valid?
  end

  it 'requires a survey' do
    @question.survey = nil
    assert @question.invalid?
  end

  it 'requires a prompt' do
    @question.prompt = nil
    assert @question.invalid?
  end

  it 'rejects lengthy prompts' do
    @question.prompt = 'p' * (1.kilobyte + 1)
    assert @question.invalid?
  end

  it 'requires a flag for allowing comments' do
    @question.allows_comments = nil
    assert @question.invalid?
  end

  describe '#can_answer?' do
    describe 'the survey is published' do
      it 'lets any user answer this question' do
        question.survey.update! published: true
        assert_equal true, question.can_answer?(any_user)
        assert_equal false, question.can_answer?(nil)
      end
    end

    describe 'the survey is not published' do
      it 'lets only staff and course/site admins answer this question' do
        question.survey.update! published: false
        assert_equal false, question.can_answer?(any_user)
        assert_equal true, question.can_answer?(users(:main_staff))
        assert_equal true, question.can_answer?(users(:admin))
        assert_equal false, question.can_answer?(nil)
      end
    end
  end

  describe 'quantitative-open-question-specific features' do
    it 'validates fixture questions (validate JSON serialization)' do
      assert question.valid?
    end

    it 'requires a step size' do
      @question.step_size = nil
      assert @question.invalid?
    end

    it 'requires the step size to be a positive number' do
      @question.step_size = -1
      assert @question.invalid?
    end

    it 'requires the step size to be less than 1000000' do
      @question.step_size = 1000000
      assert @question.invalid?
    end
  end
end
