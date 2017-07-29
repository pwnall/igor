require 'test_helper'

class SurveyQuestionsHelperTest < ActionView::TestCase
  include SurveyQuestionsHelper

  let(:qo_question) { survey_questions(:hours) }
  let(:qs_question) { survey_questions(:coding_amount) }

  describe '#question_types_for_select' do
    it 'has an <option> for each type of SurveyQuestion' do
      render html: question_types_for_select
      assert_select 'option[value=QuantitativeOpenQuestion]',
                    'Open-ended Numeric Response'
      assert_select 'option[value=QuantitativeScaledQuestion]',
                    'Rate on a scale of x to n'
    end
  end

  describe '#survey_question_prompt_placeholder' do
    it 'returns the appropriate question for the question type' do
      assert_match /many hours/, survey_question_prompt_placeholder(qo_question)
      assert_match /difficult/, survey_question_prompt_placeholder(qs_question)
      assert_raises(RuntimeError) do
        survey_question_prompt_placeholder(SurveyQuestion.new)
      end
    end
  end
end
