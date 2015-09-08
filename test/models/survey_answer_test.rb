require 'test_helper'

class SurveyAnswerTest < ActiveSupport::TestCase
  before do
    @answer = SurveyAnswer.new question: survey_questions(:hours),
        response: survey_responses(:dexter_ps1), number: 2.5
  end

  let(:answer) { survey_answers(:dexter_coding_amount) }

  it 'validates the setup answer' do
    assert @answer.valid?
  end

  it 'requires a survey question' do
    @answer.question = nil
    assert @answer.invalid?
  end

  it 'forbids a response from having multiple answers to a question' do
    @answer.question = answer.question
    assert @answer.invalid?
  end

  it 'requires a survey response' do
    @answer.response = nil
    assert @answer.invalid?
  end

  it 'requires the question and the response to belong to the same survey' do
    @answer.response = survey_responses(:dexter_project)
    assert @answer.invalid?
  end

  it 'allows :number to be nil' do
    @answer.number = nil
    assert @answer.valid?
  end

  it 'rejects negative values for :number' do
    @answer.number = -1
    assert @answer.invalid?
  end

  it 'rejects values greater than or equal to 10 million for :number' do
    @answer.number = 10000000
    assert @answer.invalid?
  end

  it 'allows :comment to be nil' do
    @answer.comment = nil
    assert @answer.valid?
  end

  it 'rejects lengthy comments' do
    @answer.comment = 'c' * (1.kilobyte + 1)
    assert @answer.invalid?
  end

  describe '#comment=' do
    it 'nullifies :comment if the comment text is blank' do
      assert_not_nil answer.comment
      answer.update! comment: '   '
      assert_nil answer.reload.comment
    end

    it 'sets :comment to the comment text if it is not blank' do
      assert_equal 'Much code', answer.comment
      answer.update! comment: 'Such labor'
      assert_equal 'Such labor', answer.comment
    end
  end
end
