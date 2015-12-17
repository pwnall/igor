require 'test_helper'

class AnalysesControllerTest < ActionController::TestCase
  before { set_session_current_user users(:dexter) }

  let(:analysis) { analyses(:dexter_assessment) }
  let(:refresh_params) do
    { id: analysis.to_param, course_id: courses(:main).to_param }
  end

  describe 'XHR GET :refresh' do
    it 'renders the icon for the current status of the given analysis' do
      assert_equal :queued, analysis.status
      get :refresh, params: refresh_params, xhr: true
      assert_response :success
      assert_select 'span.analysis-status-icon i[title="Queued"]'
    end
  end
end
