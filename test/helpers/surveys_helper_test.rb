require 'test_helper'

class SurveyResponsesHelperTest < ActionView::TestCase
  include SurveysHelper

  describe '#survey_release_text' do
    it "returns 'Pull release' if the survey is released" do
      survey = surveys(:ps1)
      assert_equal true, survey.released?
      assert_equal 'Pull release', survey_release_text(survey)
    end

    it "returns 'Release' if the survey is not released" do
      survey = surveys(:project)
      assert_equal false, survey.released?
      assert_equal 'Release', survey_release_text(survey)
    end
  end
end
