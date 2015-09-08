require 'test_helper'

class SurveyResponsesHelperTest < ActionView::TestCase
  include SurveysHelper

  describe '#survey_publish_text' do
    it "returns 'Unpublish' if the survey is published" do
      survey = surveys(:ps1)
      assert_equal true, survey.published?
      assert_equal 'Unpublish', survey_publish_text(survey)
    end

    it "returns 'Publish' if the survey is not published" do
      survey = surveys(:project)
      assert_equal false, survey.published?
      assert_equal 'Publish', survey_publish_text(survey)
    end
  end
end
