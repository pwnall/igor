require 'test_helper'

class ExamSessionsHelperTest < ActionView::TestCase
  include ExamSessionsHelper

  let(:open_session) { exam_sessions(:main_exam_under_capacity) }
  let(:full_session) { exam_sessions(:main_exam_full_capacity) }
  let(:long_session) { exam_sessions(:not_main_exam) }

  describe '#attendance_status_display' do
    describe 'the student can check in to the session' do
      it 'returns a check-in button' do
        render text: attendance_status_display(open_session, users(:deedee))
        assert_select 'form.button_to input[type="submit"][value="Check in"]'
      end
    end

    describe 'the session has reached capacity' do
      it 'returns text with a tooltip' do
        render text: attendance_status_display(full_session, users(:deedee))
        assert_select "span:match('title', ?)", /check-in elsewhere/,
            { text: 'Room full' }
      end
    end

    describe 'the user is not a student in the course' do
      it 'returns a disabled check-in button' do
        render text: attendance_status_display(open_session, users(:main_staff))
        assert_select 'button[disabled="disabled"]', 'Check in'
      end
    end

    describe 'the student has already checked in to another session' do
      it 'returns a disabled check-in button' do
        render text: attendance_status_display(open_session, users(:solo))
        assert_select 'button[disabled="disabled"]', 'Check in'
      end
    end

    describe 'the student has already checked in to this session' do
      it 'returns text with a tooltip' do
        render text: attendance_status_display(open_session, users(:dexter))
        assert_select "span:match('title', ?)", /scheduled to take the exam/,
            { text: 'Checked in!' }
      end
    end

    describe "the student's attendance to this session must be confirmed" do
      it 'returns text with a tooltip' do
        render text: attendance_status_display(full_session, users(:solo))
        assert_select "span:match('title', ?)", /staff member must confirm/,
            { text: 'Awaiting confirmation' }
      end
    end
  end

  describe '#exam_session_time_tag' do
    it 'returns the date only once if session starts and ends on same day' do
      assert_operator open_session.ends_at - open_session.starts_at, :<, 1.day
      start_date, end_date = exam_session_time_tag(open_session).split(' - ')
      assert_equal open_session.starts_at.to_s(:exam_session_datetime),
                   start_date
      assert_equal open_session.ends_at.to_s(:exam_session_time), end_date
    end

    it 'returns both start and end dates if they are on different days' do
      assert_operator long_session.ends_at - long_session.starts_at, :>, 1.day
      start_date, end_date = exam_session_time_tag(long_session).split(' - ')
      assert_equal long_session.starts_at.to_s(:exam_session_datetime),
                   start_date
      assert_equal long_session.ends_at.to_s(:exam_session_datetime), end_date
    end
  end
end
