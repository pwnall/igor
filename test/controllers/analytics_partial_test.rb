require 'test_helper'

class AnalyticsPartialTest < ActionController::TestCase
  tests SessionController

  setup do
    @user = users(:dexter)
    @course = courses(:main)
  end

  test 'no user, no course' do
    get :show

    assert_no_match(/www\.google-analytics\.com/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'user, no course' do
    set_session_current_user @user
    get :show

    assert_no_match(/www\.google-analytics\.com/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'no user, course without analytics' do
    @course.update! ga_account: nil
    get :show, params: { course_id: @course.number }

    assert_no_match(/www\.google-analytics\.com/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'user, course without analytics' do
    set_session_current_user @user
    @course.update! ga_account: nil
    get :show, params: { course_id: @course.number }

    assert_no_match(/www\.google-analytics\.com/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'user, course with Google Analytics' do
    @user.update! exuid: '4242'
    set_session_current_user @user
    @course.update! ga_account: 'GA-account'
    get :show, params: { course_id: @course.number }

    assert_match(/www\.google-analytics\.com/, response.body)
    assert_match(/ga\('create', 'GA-account'/, response.body)
    assert_match(/ga\('set', 'userId', '4242'/, response.body)
    assert_match(/ga\('send', 'pageview'/, response.body)
  end

  test 'no user, course with Google Analytics' do
    @course.update! ga_account: 'GA-account'
    get :show, params: { course_id: @course.number }

    assert_match(/www\.google-analytics\.com/, response.body)
    assert_match(/ga\('create', 'GA-account'/, response.body)
    assert_no_match(/ga\('set'/, response.body)
    assert_match(/ga\('send', 'pageview'/, response.body)
  end
end
