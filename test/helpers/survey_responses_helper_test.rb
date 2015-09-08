require 'test_helper'

class SurveyResponsesHelperTest < ActionView::TestCase
  include SurveyResponsesHelper

  describe '#response_for' do
    let(:existing_responder) { users(:dexter) }
    let(:new_responder) { users(:deedee) }
    let(:survey) { surveys(:ps1) }
    let(:response) { survey_responses(:dexter_ps1) }

    before do
      assert_not_nil survey.responses.find_by user: existing_responder
      assert_nil survey.responses.find_by user: new_responder
    end

    describe 'the previous survey response was valid' do
      describe 'the user has an existing response to the survey' do
        it 'returns the existing response' do
          assert_equal response, response_for(nil, existing_responder, survey)
        end
      end

      describe 'the user does not have a response to the survey' do
        it 'returns a new response for the user to the survey' do
          result = response_for nil, new_responder, survey
          assert_equal true, result.instance_of?(SurveyResponse)
          assert_equal true, result.new_record?
          assert_equal new_responder, result.user
          assert_equal survey, result.survey
          assert_equal survey.course, result.course
        end
      end
    end

    describe 'the previous survey response was invalid' do
      before do
        @invalid_response = survey.responses.build user: new_responder
        @invalid_response.answers_attributes = [
          { question: survey.questions.first, number: -1 }
        ]
        assert @invalid_response.invalid?
      end

      describe "the previous response's survey matches the given survey" do
        before { assert_equal @invalid_response.survey, survey }

        it 'returns the previous invalid response' do
          assert_equal @invalid_response,
              response_for(@invalid_response, new_responder, survey)
        end
      end

      describe 'the previous response belongs to a different survey' do
        before { assert_not_equal @invalid_response.survey, surveys(:project) }

        let(:another_survey) { surveys(:project) }

        it 'returns a new response for the user to the given survey' do
          result = response_for @invalid_response, new_responder, another_survey
          assert_equal true, result.instance_of?(SurveyResponse)
          assert_equal true, result.new_record?
          assert_equal new_responder, result.user
          assert_equal another_survey, result.survey
          assert_equal another_survey.course, result.course
        end
      end
    end
  end
end
