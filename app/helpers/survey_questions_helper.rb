module SurveyQuestionsHelper
  # The SurveyQuestion types as option tags.
  def question_types_for_select
    options_for_select({
      'Open-ended Numeric Response' => 'QuantitativeOpenQuestion',
      'Rate on a scale of x to n' => 'QuantitativeScaledQuestion'
    })
  end

  # The prompt placeholder to use for the given survey question.
  def survey_question_prompt_placeholder(question)
    case question
    when QuantitativeOpenQuestion
      'How many hours did you spend on this assignment?'
    when QuantitativeScaledQuestion
      'How difficult was this assignment for you?'
    else
      raise "Un-implemented survey question type: #{question.inspect}"
    end
  end
end
