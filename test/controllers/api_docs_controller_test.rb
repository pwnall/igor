require 'test_helper'

class ApiDocsControllerTest < ActionController::TestCase
  fixtures :users

  before do
    @user = users(:deedee)
    set_session_current_user users(:deedee)
  end

  it "must not crash on /api_docs" do
    get :index
    assert_response :success, response.body
  end
end
