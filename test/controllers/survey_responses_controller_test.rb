require 'test_helper'

class SurveyResponsesControllerTest < ActionController::TestCase
  let(:survey) { surveys(:ps1) }
  let(:question) { survey_questions(:coding_amount) }

  describe 'authenticated as a registered student' do
    describe 'GET #index' do
      before { set_session_current_user users(:dexter) }

      it 'forbids access to the page' do
        get :index, params: { survey_id: survey.to_param,
                              course_id: courses(:main).to_param }
        assert_response :forbidden
      end
    end

    describe 'POST #create' do
      before do
        assert_nil survey.responses.find_by user: users(:deedee)
        set_session_current_user users(:deedee)
      end
      let(:create_params) do
        { course_id: courses(:main).to_param, survey_id: survey.to_param,
          survey_response: { answers_attributes:
          { 0 => { question_id: question.to_param, number: 6 } } } }
      end

      describe 'all response answers are valid' do
        it 'creates a new response' do
          assert_difference 'SurveyResponse.count' do
            post :create, params: create_params
          end
          assert_equal survey, SurveyResponse.last.survey
          assert_equal users(:deedee), SurveyResponse.last.user
        end

        it 'redirects to the surveys index page' do
          post :create, params: create_params
          assert_redirected_to survey_url(survey, course_id: survey.course)
        end
      end

      describe 'the response is invalid' do
        before do
          create_params[:survey_response][:answers_attributes][0][:number] =
              10000000
        end

        it 'does not create any new responses' do
          assert_no_difference 'SurveyResponse.count' do
            post :create, params: create_params
          end
        end

        it 're-renders the survey form with an error messageß' do
          post :create, params: create_params
          assert_response :success
          assert_select 'div.errorExplanation li', 1
        end
      end
    end

    describe 'PATCH #update' do
      before { set_session_current_user users(:dexter) }
      let(:dexter_response) do
        users(:dexter).survey_responses.find_by survey: survey
      end
      let(:existing_answer) do
        dexter_response.answers.find_by question: question
      end
      let(:member_params) do
        { id: dexter_response.to_param, course_id: courses(:main).to_param,
          survey_id: survey.to_param, survey_response: { answers_attributes:
          { 0 => { id: existing_answer.to_param, question_id: question.to_param,
          number: '6' } } } }
      end

      describe 'all response answers are valid' do
        it 'updates new answers in the response' do
          existing_answer = survey_answers(:dexter_coding_amount)
          assert_equal 3, existing_answer.number
          patch :update, params: member_params
          assert_equal 6, existing_answer.reload.number
        end

        it 'redirects to the surveys index page' do
          patch :update, params: member_params
          assert_redirected_to survey_url(survey, course_id: survey.course)
        end
      end

      describe 'the response is invalid' do
        before do
          member_params[:survey_response][:answers_attributes][0][:number] =
              10000000
        end

        it 'does not create or change any responses' do
          existing_answer = survey_answers(:dexter_coding_amount)
          assert_equal 3, existing_answer.number
          assert_no_difference 'SurveyResponse.count' do
            patch :update, params: member_params
          end
          assert_equal 3, existing_answer.reload.number
        end

        it 're-renders the survey form with an error message' do
          patch :update, params: member_params
          assert_response :success
          assert_select 'div.errorExplanation li', 1
        end
      end
    end
  end

  describe 'authenticated as a course editor' do
    before { set_session_current_user users(:admin) }

    describe 'GET #index' do
      it 'shows the responses for the given survey' do
        get :index, params: { survey_id: survey.to_param,
                              course_id: courses(:main).to_param }

        assert_response :success
        assert_select 'h2', /#{survey.name}/
      end
    end
  end
end
