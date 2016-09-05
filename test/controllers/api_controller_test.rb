require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  describe '/0/user_info' do
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
      assert_response :ok, response.body
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
      assert_response :ok, response.body
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
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end
  end

  describe '/0/assignments' do
    it 'requires token authentication' do
      set_session_current_user nil
      get :assignments, format: 'json', params: { course: '6.006' }
      assert_response :ok, response.body
      assert_match(/sign in/,
                   ActiveSupport::JSON.decode(response.body)['error'])

      set_session_current_user users(:admin)
      get :assignments, format: 'json', params: { course: '6.006' }
      assert_response :ok, response.body
      assert_match(/sign in/,
                   ActiveSupport::JSON.decode(response.body)['error'])

      set_http_token_user users(:deedee)
      get :assignments, format: 'json', params: { course: '6.006' }
      assert_response :ok, response.body
      assert_kind_of Array, ActiveSupport::JSON.decode(response.body)
    end

    it 'errors out when the course is missing' do
      set_http_token_user users(:deedee)
      get :assignments, format: 'json', params: {}
      assert_response :ok, response.body
      assert_match(/not found/,
                   ActiveSupport::JSON.decode(response.body)['error'])
    end

    it 'handles an assignment with a deliverable and a metric' do
      courses(:main).assignments.reject { |a| a == assignments(:ps1) }.
                     each(&:destroy)

      set_http_token_user users(:deedee)
      get :assignments, format: 'json', params: { course: '6.006' }
      golden = [{
        'name' => 'PSet 1',
        'stated_deadline' => assignments(:ps1).due_at.iso8601,
        'due_at' => assignments(:ps1).due_at.iso8601,
        'deliverables' => [{
          'id' => deliverables(:ps1_writeup).id.to_s,
          'name' => 'PDF Write-Up',
        }],
        'metrics' => [{
          'name' => 'Problem 1',
          'max_score' => 10,
          'weight' => 5.0,
        }],
      }]
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end

    it 'handles an assignment with no deliverables' do
      courses(:main).assignments.reject { |a| a == assignments(:ps1) }.
                     each(&:destroy)
      assignments(:ps1).deliverables.destroy_all
      set_http_token_user users(:deedee)
      get :assignments, format: 'json', params: { course: '6.006' }
      golden = [{
        'name' => 'PSet 1',
        'stated_deadline' => assignments(:ps1).due_at.iso8601,
        'due_at' => assignments(:ps1).due_at.iso8601,
        'deliverables' => [],
        'metrics' => [{
          'name' => 'Problem 1',
          'max_score' => 10,
          'weight' => 5.0,
        }],
      }]
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end

    it 'handles an assignment with no metrics' do
      courses(:main).assignments.reject { |a| a == assignments(:ps1) }.
                     each(&:destroy)
      assignments(:ps1).metrics.destroy_all

      set_http_token_user users(:deedee)
      get :assignments, format: 'json', params: { course: '6.006' }
      golden = [{
        'name' => 'PSet 1',
        'stated_deadline' => assignments(:ps1).due_at.iso8601,
        'due_at' => assignments(:ps1).due_at.iso8601,
        'deliverables' => [{
          'id' => deliverables(:ps1_writeup).id.to_s,
          'name' => 'PDF Write-Up',
        }],
        'metrics' => [],
      }]
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end

    it 'hides metrics in an assignment w/o published grades from students' do
      courses(:main).assignments.reject { |a| a == assignments(:ps1) }.
                     each(&:destroy)
      assignments(:ps1).update! grades_released: false

      set_http_token_user users(:deedee)
      get :assignments, format: 'json', params: { course: '6.006' }
      golden = [{
        'name' => 'PSet 1',
        'stated_deadline' => assignments(:ps1).due_at.iso8601,
        'due_at' => assignments(:ps1).due_at.iso8601,
        'deliverables' => [{
          'id' => deliverables(:ps1_writeup).id.to_s,
          'name' => 'PDF Write-Up',
        }],
        'metrics' => [],
      }]
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end

    it 'shows metrics in an assignment w/o published grades to staff' do
      courses(:main).assignments.reject { |a| a == assignments(:ps1) }.
                     each(&:destroy)
      assignments(:ps1).update! grades_released: false

      set_http_token_user users(:main_staff)
      get :assignments, format: 'json', params: { course: '6.006' }
      golden = [{
        'name' => 'PSet 1',
        'stated_deadline' => assignments(:ps1).due_at.iso8601,
        'due_at' => assignments(:ps1).due_at.iso8601,
        'deliverables' => [{
          'id' => deliverables(:ps1_writeup).id.to_s,
          'name' => 'PDF Write-Up',
        }],
        'metrics' => [{
          'name' => 'Problem 1',
          'max_score' => 10,
          'weight' => 5.0,
        }],
      }]
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end

    it 'hides everything in an unpublished assignment from students' do
      courses(:main).assignments.reject { |a| a == assignments(:ps1) }.
                     each(&:destroy)
      deadlines(:ps1).update! due_at: 1.week.from_now
      assignments(:ps1).update! released_at: 1.day.from_now,
                                grades_released: false

      set_http_token_user users(:deedee)
      get :assignments, format: 'json', params: { course: '6.006' }
      golden = []
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end

    it 'shows everything in an unpublished assignment to staff' do
      courses(:main).assignments.reject { |a| a == assignments(:ps1) }.
                     each(&:destroy)
      deadlines(:ps1).update! due_at: 1.week.from_now
      assignments(:ps1).update! released_at: 1.day.from_now,
                                grades_released: false

      set_http_token_user users(:main_staff)
      get :assignments, format: 'json', params: { course: '6.006' }
      golden = [{
        'name' => 'PSet 1',
        'stated_deadline' => assignments(:ps1).due_at.iso8601,
        'due_at' => assignments(:ps1).due_at.iso8601,
        'deliverables' => [{
          'id' => deliverables(:ps1_writeup).id.to_s,
          'name' => 'PDF Write-Up',
        }],
        'metrics' => [{
          'name' => 'Problem 1',
          'max_score' => 10,
          'weight' => 5.0,
        }],
      }]
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end
  end

  describe '/0/submissions' do
    it 'requires token authentication' do
      set_session_current_user nil
      get :submissions, format: 'json', params: { course: '6.006' }
      assert_response :ok, response.body
      assert_match(/sign in/,
                   ActiveSupport::JSON.decode(response.body)['error'])

      set_session_current_user users(:admin)
      get :submissions, format: 'json', params: { course: '6.006' }
      assert_response :ok, response.body
      assert_match(/sign in/,
                   ActiveSupport::JSON.decode(response.body)['error'])

      set_http_token_user users(:dexter)
      get :submissions, format: 'json', params: { course: '6.006' }
      assert_response :ok, response.body
      assert_kind_of Array, ActiveSupport::JSON.decode(response.body)
    end

    it 'errors out when the course is missing' do
      set_http_token_user users(:dexter)
      get :submissions, format: 'json', params: {}
      assert_response :ok, response.body
      assert_match(/not found/,
                   ActiveSupport::JSON.decode(response.body)['error'])
    end

    it 'handles graded submissions' do
      set_http_token_user users(:deedee)
      get :submissions, format: 'json', params: { course: '6.006' }
      golden = [{
        'deliverable_id' => deliverables(:assessment_writeup).id.to_s,
        'submitted_at' => submissions(:deedee_assessment).updated_at.iso8601,
        'analysis' => {
          'status' => 'queued',
          'scores' => {
            'Quality' => 1.0,
            'Overall' => 1.0
          }
        }
      }]
      assert_response :ok, response.body
      assert_equal golden, ActiveSupport::JSON.decode(response.body)
    end
  end
end
