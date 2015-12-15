require 'test_helper'

class ExamSessionsHelperTest < ActionView::TestCase
  include ExamSessionsHelper

  let(:open_session) { exam_sessions(:main_exam_under_capacity) }
  let(:full_session) { exam_sessions(:main_exam_full_capacity) }
  let(:long_session) { exam_sessions(:not_main_exam) }
  let(:unreleased_exam) { assignments(:main_exam) }
  let(:undecided_assignment) { assignments(:main_exam_2) }

  describe '#exam_session_checkin_options' do
    it 'returns an <option> for each session of the given exam' do
      render text: exam_session_checkin_options(unreleased_exam.exam)
      assert_select 'option', unreleased_exam.exam.exam_sessions.count
    end

    it 'pre-selects the specified session' do
      render text: exam_session_checkin_options(unreleased_exam.exam,
                                                open_session)
      assert_select "option[selected='selected'][value='#{open_session.id}']"
    end
  end

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
      render text: exam_session_time_tag(open_session)
      assert_select 'span.time' do |elements|
        elements.each_with_index do |element, i|
          if i == 0
            start_date = open_session.starts_at.to_s(:exam_session_date)
            assert_equal start_date + ', ', element.text
          elsif i == 1
            start_time = open_session.starts_at.to_s(:exam_session_time)
            end_time = open_session.ends_at.to_s(:exam_session_time)
            assert_equal start_time + ' - ' + end_time, element.text
          else
            assert false
          end
        end
      end
    end

    it 'returns both start and end dates if they are on different days' do
      assert_operator long_session.ends_at - long_session.starts_at, :>, 1.day
      render text: exam_session_time_tag(long_session)
      assert_select 'span.time' do |elements|
        elements.each_with_index do |element, i|
          if i == 0
            start_datetime = long_session.starts_at.to_s(:exam_session_datetime)
            assert_equal start_datetime + ' - ', element.text
          elsif i == 1
            end_datetime = long_session.ends_at.to_s(:exam_session_datetime)
            assert_equal end_datetime, element.text
          else
            assert false
          end
        end
      end
    end
  end

  describe '#exam_session_start_time' do
    describe 'for new ExamSession records' do
      it 'formats the assignment release date, if it is not nil' do
        assert_not_nil unreleased_exam.released_at
        golden = unreleased_exam.released_at.to_s(:datetime_local_field)
        actual = exam_session_start_time unreleased_exam.exam.exam_sessions.new
        assert_equal golden, actual
      end

      it 'formats the assignment due date, if the release date is nil' do
        assert_nil undecided_assignment.released_at
        exam = undecided_assignment.create_exam! requires_confirmation: false
        golden = undecided_assignment.due_at.to_s(:datetime_local_field)
        actual = exam_session_start_time exam.exam_sessions.new
        assert_equal golden, actual
      end
    end

    describe 'for existing ExamSession records' do
      it 'returns the session start time' do
        assert_equal false, open_session.new_record?
        golden = open_session.starts_at.to_s(:datetime_local_field)
        actual = exam_session_start_time open_session
        assert_equal golden, actual
      end
    end
  end

  describe '#exam_session_end_time' do
    describe 'for new ExamSession records' do
      it 'formats the assignment due date, if the release date is nil' do
        assert_nil undecided_assignment.released_at
        exam = undecided_assignment.create_exam! requires_confirmation: false
        golden = undecided_assignment.due_at.to_s(:datetime_local_field)
        actual = exam_session_end_time exam.exam_sessions.new
        assert_equal golden, actual
      end
    end

    describe 'for existing ExamSession records' do
      it 'returns the session end time' do
        assert_equal false, open_session.new_record?
        golden = open_session.ends_at.to_s(:datetime_local_field)
        actual = exam_session_end_time open_session
        assert_equal golden, actual
      end
    end
  end
end
