module SurveyResponsesHelper
  # The object of a response form.
  #
  # @param [SurveyResponse] invalid_response a response from the previous
  #     request, if it failed validations; otherwise, nil
  # @param [User] user the author of the survey answers
  # @param [Survey] survey the survey that this response addresses
  # @return [SurveyResponse] the student's previous invalid response for the
  #     survey, existing valid response to the survey, or a new response
  def response_for(invalid_response, user, survey)
    if invalid_response && (invalid_response.survey == survey)
      invalid_response
    else
      SurveyResponse.where(user: user, survey: survey, course: survey.course).
                     first_or_initialize
    end
  end
end
