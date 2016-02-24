require 'test_helper'

class AnalysesControllerTest < ActionController::TestCase
  describe 'authenticated as a registered student' do
    before { set_session_current_user user }
    let(:user) { users(:dexter) }
    let(:analysis) { analyses(:dexter_assessment) }
    let(:member_params) do
      { id: analysis.to_param, course_id: courses(:main).to_param }
    end

    describe 'GET #show' do
      it 'can render your own analysis' do
        get :show, params: member_params
        assert_response :success
      end
    end

    describe 'XHR GET :refresh' do
      it 'renders the icon for the current status of the given analysis' do
        assert_equal :queued, analysis.status
        get :refresh, params: member_params, xhr: true
        assert_response :success
        assert_select 'span.analysis-status-icon i[title="Queued"]'
      end
    end
  end

  describe 'authenticated as a course editor' do
    before { set_session_current_user user }
    let(:user) { users(:main_staff) }
    let(:analysis) { analyses(:main_staff_code) }
    let(:member_params) do
      { id: analysis.to_param, course_id: courses(:main).to_param }
    end

    describe 'GET #show' do
      it 'can render your own analysis' do
        get :show, params: member_params
        assert_response :success
      end
    end

    describe 'XHR GET :refresh' do
      it 'renders the icon for the current status of the given analysis' do
        assert_equal :ok, analysis.status
        get :refresh, params: member_params, xhr: true
        assert_response :success
        assert_select 'span.analysis-status-icon i[title="OK"]'
      end
    end
  end
end
