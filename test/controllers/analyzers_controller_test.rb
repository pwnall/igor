require 'test_helper'

class AnalyzersControllerTest < ActionController::TestCase
  fixtures :users

  before do
    @user = users(:admin)
    set_session_current_user users(:admin)
  end

  it "must not crash on /analyzers/help" do
    get :help, params: { course_id: courses(:main).to_param }
    assert_response :success, response.body
  end
end
