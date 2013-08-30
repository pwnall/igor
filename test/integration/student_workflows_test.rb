require 'test_helper'

class StudentWorkflowsTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  #Basic sign in and submit.
  #1.	Sign in
  #2.	Go to Homework tab. Click on a Problem Set
  #3.	Upload file. Verify: homework is submitted (Submission created, etc).
  #4.	Sign off
  
  def user_for_test
    open_session do |user|
      def user.try_to_signin
        get '/'
        assert_response :success
        request.session[:user_id] = users(:dexter).to_param
        assert_not_nil request.session[:user_id]
        puts request.session.inspect
      end
      def user.homework_tab(assn)
        puts request.session.inspect
        assert_not_nil request.session[:user_id]
        user = User.find_by_id request.session[:user_id]
        get '/assignments', id: assn.id
        assert_response :success
      end
    end
  end
  
  test "basic sign in and submit homework" do
    user = user_for_test
    user.try_to_signin
    user.homework_tab(assignments(:ps2))
  end
  
  
  
  
end