require 'test_helper'

class AnalyticsPartialTest < ActionController::TestCase
  tests SessionController

  setup do
    @user = users(:dexter)
    @course = courses(:main)
  end

  test 'no user, no course' do
    get :show

    assert_no_match(/cdn\.heapanalytics\.com/, response.body)
    assert_no_match(/www\.google-analytics\.com/, response.body)

    assert_no_match(/heap\.load/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'user, no course' do
    set_session_current_user @user
    get :show

    assert_no_match(/cdn\.heapanalytics\.com/, response.body)
    assert_no_match(/www\.google-analytics\.com/, response.body)

    assert_no_match(/heap\.load/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'no user, course without analytics' do
    @course.update! ga_account: nil, heap_appid: nil
    get :show, params: { course_id: @course.number }

    assert_no_match(/cdn\.heapanalytics\.com/, response.body)
    assert_no_match(/www\.google-analytics\.com/, response.body)

    assert_no_match(/heap\.load/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'user, course without analytics' do
    set_session_current_user @user
    @course.update! ga_account: nil, heap_appid: nil
    get :show, params: { course_id: @course.number }

    assert_no_match(/cdn\.heapanalytics\.com/, response.body)
    assert_no_match(/www\.google-analytics\.com/, response.body)

    assert_no_match(/heap\.load/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'no user, course with Heap' do
    @course.update! ga_account: nil, heap_appid: 'heap-app-id'
    get :show, params: { course_id: @course.number }

    assert_match(/cdn\.heapanalytics\.com/, response.body)
    assert_no_match(/www\.google-analytics\.com/, response.body)

    assert_match(/heap\.load\("heap-app-id"/, response.body)
    assert_no_match(/heap\.identify\(/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'user, course with Heap' do
    @user.update! exuid: '4242'
    set_session_current_user @user
    @course.update! ga_account: nil, heap_appid: 'heap-app-id'
    get :show, params: { course_id: @course.number }

    assert_match(/cdn\.heapanalytics\.com/, response.body)
    assert_no_match(/www\.google-analytics\.com/, response.body)

    assert_match(/heap\.load\("heap-app-id"/, response.body)
    assert_match(/heap\.identify\({handle: 'exuid-4242'/, response.body)
    assert_no_match(/ga\('create'/, response.body)
  end

  test 'no user, course with Google Analytics' do
    @course.update! ga_account: 'GA-account', heap_appid: nil
    get :show, params: { course_id: @course.number }

    assert_no_match(/cdn\.heapanalytics\.com/, response.body)
    assert_match(/www\.google-analytics\.com/, response.body)

    assert_no_match(/heap\.load\("heap-app-id"/, response.body)
    assert_no_match(/heap\.identify\(/, response.body)
    assert_match(/ga\('create', 'GA-account'/, response.body)
    assert_no_match(/ga\('set'/, response.body)
    assert_match(/ga\('send', 'pageview'/, response.body)
  end

  test 'user, course with Google Analytics' do
    @user.update! exuid: '4242'
    set_session_current_user @user
    @course.update! ga_account: 'GA-account', heap_appid: nil
    get :show, params: { course_id: @course.number }

    assert_no_match(/cdn\.heapanalytics\.com/, response.body)
    assert_match(/www\.google-analytics\.com/, response.body)

    assert_no_match(/heap\.load\("heap-app-id"/, response.body)
    assert_no_match(/heap\.identify\(/, response.body)
    assert_match(/ga\('create', 'GA-account'/, response.body)
    assert_match(/ga\('set', '&uid', '4242'/, response.body)
    assert_match(/ga\('send', 'pageview'/, response.body)
  end

  test 'no user, course with Heap and Google Analytics' do
    @course.update! ga_account: 'GA-account', heap_appid: 'heap-app-id'
    get :show, params: { course_id: @course.number }

    assert_match(/cdn\.heapanalytics\.com/, response.body)
    assert_match(/www\.google-analytics\.com/, response.body)

    assert_match(/heap\.load\("heap-app-id"/, response.body)
    assert_no_match(/heap\.identify\(/, response.body)
    assert_match(/ga\('create', 'GA-account'/, response.body)
    assert_no_match(/ga\('set'/, response.body)
    assert_match(/ga\('send', 'pageview'/, response.body)
  end

  test 'user, course with Heap and Google Analytics' do
    @user.update! exuid: '4242'
    set_session_current_user @user
    @course.update! ga_account: 'GA-account', heap_appid: 'heap-app-id'
    get :show, params: { course_id: @course.number }

    assert_match(/cdn\.heapanalytics\.com/, response.body)
    assert_match(/www\.google-analytics\.com/, response.body)

    assert_match(/heap\.load\("heap-app-id"/, response.body)
    assert_match(/heap\.identify\({handle: 'exuid-4242'/, response.body)
    assert_match(/ga\('create', 'GA-account'/, response.body)
    assert_match(/ga\('set', '&uid', '4242'/, response.body)
    assert_match(/ga\('send', 'pageview'/, response.body)
  end
end
