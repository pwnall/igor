require 'test_helper'

class ExamAttendanceTest < ActiveSupport::TestCase
  before do
    @exam_session = exam_sessions(:main_exam_under_capacity)
    @attendance = ExamAttendance.new user: users(:deedee),
        exam_session: @exam_session, confirmed: false
  end

  let(:attendance) { exam_attendances(:dexter_under_capacity) }
  let(:full_session) { exam_sessions(:main_exam_full_capacity) }

  it 'validates the setup attendance' do
    assert @attendance.valid?, @attendance.errors.full_messages
  end

  it 'requires a user' do
    @attendance.user = nil
    assert @attendance.invalid?
  end

  it 'forbids a user from attending multiple sessions for the same exam' do
    @attendance.user = users(:solo)
    assert @attendance.invalid?
  end

  it 'forbids staff from attending an exam session' do
    @attendance.user = users(:main_staff)
    assert @attendance.invalid?
  end

  it 'forbids unregistered users from attending an exam session' do
    @attendance.user = users(:inactive)
    assert @attendance.invalid?
  end

  it "requires that the exam matches the exam session's course" do
    @attendance.exam = exams(:not_main_exam)
    assert @attendance.invalid?
  end

  it "sets the attendance's exam to that of the exam session" do
    assert_equal @exam_session.exam, @attendance.exam
    @attendance.exam_session = exam_sessions(:not_main_exam)
    assert_equal exams(:not_main_exam), @attendance.exam
  end

  it 'requires an exam session' do
    @attendance.exam_session = nil
    assert @attendance.invalid?
  end

  it 'rejects additional attendances to an exam session that is full' do
    assert_equal false, full_session.has_available_seats?
    new_attendance = full_session.build_attendance_for_user(users(:deedee))
    assert new_attendance.invalid?
  end

  it 'requires the :confirmed flag to be set' do
    @attendance.confirmed = nil
    assert @attendance.invalid?
  end

  describe 'by_student_name scope' do
    it 'alphabetically sorts by student name' do
      golden = users(:solo, :deedee, :dexter, :not_main_student)
      assert_equal golden, ExamAttendance.by_student_name.map(&:user)
    end
  end
end
