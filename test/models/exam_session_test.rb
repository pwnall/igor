require 'test_helper'

class ExamSessionTest < ActiveSupport::TestCase
  before do
    @starts_at = 2.days.from_now
    @ends_at = @starts_at + 3.hours
    @exam = assignments(:main_exam_2).build_exam requires_confirmation: false
    @exam_session = @exam.exam_sessions.build capacity: 2,
        name: 'Room 10, 3 hours', starts_at: @starts_at, ends_at: @ends_at
  end

  let(:exam) { exams(:main_exam) }
  let(:open_session) { exam_sessions(:main_exam_under_capacity) }
  let(:full_session) { exam_sessions(:main_exam_full_capacity) }

  it 'validates the setup exam session' do
    assert @exam_session.valid?
  end

  describe '#get_exam_course' do
    it "sets the session's course, if nil, to that of the exam" do
      assert_nil @exam_session.course
      @exam.save!
      assert_equal @exam.course, @exam_session.course
    end

    it "sets the session's course, if different, to that of the exam" do
      @exam_session.course = courses(:not_main)
      assert_not_equal @exam.course, @exam_session.course
      @exam.save!
      assert_equal @exam.course, @exam_session.course
    end
  end

  it 'requires an exam' do
    @exam_session.exam = nil
    assert @exam_session.invalid?
  end

  it 'requires a name' do
    @exam_session.name = nil
    assert @exam_session.invalid?
  end

  it 'rejects lengthy names' do
    @exam_session.name = 's' * 65
    assert @exam_session.invalid?
  end

  it 'forbids exam sessions for the same exam from sharing names' do
    full_session.name = open_session.name
    assert full_session.invalid?
  end

  it 'requires a starting time' do
    @exam_session.starts_at = nil
    assert @exam_session.invalid?
  end

  it 'requires an ending time' do
    @exam_session.ends_at = nil
    assert @exam_session.invalid?
  end

  it 'requires the end time to occur after the start time' do
    @exam_session.ends_at = @exam_session.starts_at - 1.hour
    assert @exam_session.invalid?
  end

  it 'requires a capacity' do
    @exam_session.capacity = nil
    assert @exam_session.invalid?
  end

  it 'requires the capacity to be greater than 0' do
    [0, -1].each do |capacity|
      @exam_session.capacity = capacity
      assert_equal true, @exam_session.invalid?
    end
  end

  it 'forbids the session from exceeding capacity' do
    open_session.build_attendance_for_user(users(:deedee)).save!
    open_session.capacity = 1
    assert open_session.invalid?
  end

  it 'destroys dependent records' do
    assert_not_empty open_session.attendances

    open_session.destroy

    assert_empty open_session.attendances.reload
  end

  describe '#available_seats' do
    it 'returns the number of available seats' do
      assert_equal 1, open_session.available_seats
      assert_equal 0, full_session.available_seats
    end
  end

  describe '#has_available_seats?' do
    it 'returns true if the session is not at capacity' do
      assert_equal true, open_session.has_available_seats?
    end

    it 'returns false if the session is at capacity' do
      assert_equal false, full_session.has_available_seats?
    end
  end

  describe '#can_check_in?' do
    it 'returns false if the session is at capacity' do
      assert_equal false, full_session.can_check_in?(users(:dexter))
    end

    it 'returns false if the student has already checked-in to this session' do
      assert_includes open_session.attendances.map(&:user), users(:dexter)
      assert_equal false, open_session.can_check_in?(users(:dexter))
    end

    it 'returns false if the student already checked-in to another session for
        this exam' do
      assert_not_includes open_session.attendances.map(&:user), users(:solo)
      assert_includes exam.attendances.map(&:user), users(:solo)
      assert_equal false, open_session.can_check_in?(users(:solo))
    end

    it 'returns false if the user is not a student in the course' do
      assert_equal false, open_session.can_check_in?(users(:main_staff))
      assert_equal false, open_session.can_check_in?(users(:not_main_student))
    end
  end

  describe '#ui_attendance_status_for' do
    it 'returns :unavailable if the user is not a student in the course' do
      assert_equal :unavailable,
                   open_session.ui_attendance_status_for(users(:main_staff))
    end

    describe 'the student has not checked-in for this exam' do
      before { assert_nil exam.attendances.find_by(user: users(:deedee)) }

      it 'returns :available for sessions under capacity' do
        assert_equal :available,
                     open_session.ui_attendance_status_for(users(:deedee))
      end

      it 'returns :full for sessions at capacity' do
        assert_equal :full,
                     full_session.ui_attendance_status_for(users(:deedee))
      end
    end

    describe 'the student has checked-in to this exam session' do
      before do
        @attendance = open_session.attendances.find_by(user: users(:dexter))
        assert_not_nil @attendance
      end

      it 'returns :confirmed if the attendance is confirmed' do
        @attendance.update! confirmed: true
        assert_equal :confirmed,
                     open_session.ui_attendance_status_for(users(:dexter))
      end

      it 'returns :pending_confirmation if the attendance is unconfirmed' do
        @attendance.update! confirmed: false
        assert_equal :pending_confirmation,
                     open_session.ui_attendance_status_for(users(:dexter))
      end
    end

    describe 'the student checked-in to a different session for this exam' do
      it 'returns :unavailable for sessions under capacity' do
        assert_not_nil full_session.attendances.find_by(user: users(:solo))
        assert_equal :unavailable,
                     open_session.ui_attendance_status_for(users(:solo))
      end

      it 'returns :full for sessions at capacity' do
        assert_not_nil open_session.attendances.find_by(user: users(:dexter))
        assert_equal :full,
                     full_session.ui_attendance_status_for(users(:dexter))
      end
    end
  end

  describe '#build_attendance_for_user' do
    let(:new_attendance) do
      open_session.build_attendance_for_user users(:deedee)
    end

    it 'prepares to check the user in to this exam session' do
      assert_equal users(:deedee), new_attendance.user
      assert_equal open_session, new_attendance.exam_session
      assert_equal true, new_attendance.valid?
    end

    it 'sets :confirmed to true if the exam does not require confirmation' do
      exam.update! requires_confirmation: false
      assert_equal true, new_attendance.confirmed?
    end

    it 'sets :confirmed to false if the exam requires confirmation' do
      exam.update! requires_confirmation: true
      assert_equal false, new_attendance.confirmed?
    end
  end
end
