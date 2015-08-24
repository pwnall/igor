module SurveysHelper
  # The text to show on the button that (un)publishes a survey.
  def survey_publish_text(survey)
    survey.published? ? 'Unpublish' : 'Publish'
  end
end
