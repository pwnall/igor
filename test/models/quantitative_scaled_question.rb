require 'test_helper'

class QuantitativeScaledQuestionTest < ActiveSupport::TestCase
  before do
    @question = QuantitativeScaledQuestion.new survey: surveys(:ps1),
        prompt: 'How hard was the lab?', allows_comments: false, scale_min: 1,
        scale_max: 8, scale_min_label: 'Too easy', scale_max_label: 'Too hard'
  end

  let(:question) { survey_questions(:coding_amount) }
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

  describe 'quantitative-scaled-question-specific features' do
    it 'requires a scale min' do
      @question.scale_min = nil
      assert @question.invalid?
    end

    it 'requires a scale max' do
      @question.scale_max = nil
      assert @question.invalid?
    end

    it 'requires a scale min label' do
      @question.scale_min_label = nil
      assert @question.invalid?
    end

    it 'rejects lengthy scale min labels' do
      @question.scale_min_label = 'l' * 65
      assert @question.invalid?
    end

    it 'requires a scale max label' do
      @question.scale_max_label = nil
      assert @question.invalid?
    end

    it 'rejects lengthy scale max labels' do
      @question.scale_max_label = 'l' * 65
      assert @question.invalid?
    end
  end
end
