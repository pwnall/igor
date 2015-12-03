require 'test_helper'

class DeadlineTest < ActiveSupport::TestCase
  before do
    @course = courses(:main)
    assignment_params = { name: 'PS1', author: users(:main_staff), weight: 1,
        released_at: 1.week.ago, grades_released: false }
    @assignment = @course.assignments.build assignment_params
    @deadline = @assignment.build_deadline due_at: Time.current
  end

  let(:deadline) { deadlines(:ps1) }

  it 'validates the setup deadline' do
    assert @deadline.valid?, @deadline.errors.full_messages
  end

  it 'requires a subject' do
    @deadline.subject = nil
    assert @deadline.invalid?
  end

  it 'forbids a survey/assignment from having multiple deadlines' do
    @deadline.subject = assignments(:ps1)
    assert @deadline.invalid?
  end

  it 'requires a due date' do
    @deadline.due_at = nil
    assert @deadline.invalid?
  end

  describe '#get_subject_course' do
    it "sets the deadline's course, if nil, to that of the subject" do
      assert_nil @deadline.course
      @assignment.save!
      assert_equal @assignment.course, @deadline.course
    end
  end

  describe '#course_matches_subject' do
    it "requires the assignment/survey to belong to the deadline's course" do
      deadline.course = courses(:not_main)
      assert deadline.invalid?
    end
  end
end
