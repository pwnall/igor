require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  describe '/0/get_user_info' do
    it 'requires token authentication' do
      set_session_current_user nil
      get :user_info, format: 'json'
      assert_response :ok, response.body
      assert_match(/sign in/,
                   ActiveSupport::JSON.decode(response.body)['error'])

      set_session_current_user users(:admin)
      get :user_info, format: 'json'
      assert_response :ok, response.body
      assert_match(/sign in/,
                   ActiveSupport::JSON.decode(response.body)['error'])

      set_http_token_user users(:deedee)
      get :user_info, format: 'json'
      assert_response :ok, response.body
      assert_nil ActiveSupport::JSON.decode(response.body)['error']
    end

    it 'handles site admins (no registrations, global roles)' do
      set_http_token_user users(:admin)
      get :user_info, format: 'json'
      golden = {
        'email' => 'admin@mit.edu',
        'profile' => {
          'name' => 'Admin',
          'nickname' => 'admin',
        },
        'registrations' => [],
        'roles' => [{ 'name' => 'admin', 'course' => nil }],
      }
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end

    it 'handles course staff (course roles)' do
      set_http_token_user users(:main_staff)
      get :user_info, format: 'json'
      golden = {
        'email' => 'main_staff@mit.edu',
        'profile' => {
          'name' => 'Main Staff',
          'nickname' => 'Staffy',
        },
        'registrations' => [],
        'roles' => [{ 'name' => 'staff', 'course' => '6.006' }],
      }
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end

    it 'handles students (registrations)' do
      set_http_token_user users(:deedee)
      get :user_info, format: 'json'
      golden = {
        'email' => 'costan+deedee@mit.edu',
        'profile' => {
          'name' => 'Annoying DeeDee',
          'nickname' => 'Dee',
        },
        'registrations' => [
          {'course' => '6.006', 'for_credit' => false},
          {'course' => '0.000', 'for_credit' => true},
        ],
        'roles' => [],
      }
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end
  end
end
