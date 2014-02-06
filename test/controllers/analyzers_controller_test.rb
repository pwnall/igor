require 'test_helper'

describe AnalyzersController do
  fixtures :users

  before do
    @user = users(:admin)
    set_session_current_user users(:admin)
  end

  it "must not crash on /analyzers/help" do
    get :help
    assert_response :success, response.body
  end
end
