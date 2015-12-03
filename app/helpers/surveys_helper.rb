module SurveysHelper
  # The text to show on the button that (un)releasees a survey.
  def survey_release_text(survey)
    survey.released? ? 'Pull release' : 'Release'
  end
end
