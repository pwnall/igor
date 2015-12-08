require 'test_helper'

class ExamTest < ActiveSupport::TestCase
  before do
    @exam = Exam.new assignment: assignments(:main_exam_2),
        requires_confirmation: false
  end

  let(:requires_confirmation_exam) { exams(:main_exam) }
  let(:auto_confirmed_exam) { exams(:not_main_exam) }

  it 'validates the setup exam' do
    assert @exam.valid?
  end

  it 'requires an assignment' do
    @exam.assignment = nil
    assert @exam.invalid?
  end

  it 'forbids an assignment from having multiple exams' do
    @exam.assignment = requires_confirmation_exam.assignment
    assert @exam.invalid?
  end

  it 'must state whether staff confirmation is required' do
    @exam.requires_confirmation = nil
    assert @exam.invalid?
  end

  describe '#reset_confirmations' do
    it 'unconfirms all attendances if :requires_confirmation changed to true' do
      exam = auto_confirmed_exam
      assert_equal false, exam.requires_confirmation?
      assert_not_empty exam.attendances.where(confirmed: true)
      exam.update! requires_confirmation: true
      assert_empty exam.attendances.where(confirmed: true)
    end

    it 'confirms all attendances if :requires_confirmation changed to false' do
      exam = requires_confirmation_exam
      assert_equal true, exam.requires_confirmation?
      assert_not_empty exam.attendances.where(confirmed: false)
      exam.update! requires_confirmation: false
      assert_empty exam.attendances.where(confirmed: false)
    end
  end

  it 'destroys dependent records' do
    exam = requires_confirmation_exam
    assert_not_empty exam.exam_sessions
    assert_not_empty exam.attendances

    exam.destroy

    assert_empty exam.exam_sessions.reload
    assert_empty exam.attendances.reload
  end

  it 'saves associated exam sessions through the parent exam' do
    start_time = 1.week.from_now.round 0  # Remove sub-second information.
    params = { exam: { exam_sessions_attributes: [{ name: 'Rm 1, 2x time',
      starts_at: start_time, ends_at: start_time + 2.hours, capacity: 2 }]
    } }
    assert_difference '@exam.exam_sessions.count' do
      @exam.update! params[:exam]
    end
    assert_equal start_time, @exam.exam_sessions.last.starts_at
  end
end
