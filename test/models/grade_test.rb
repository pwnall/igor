require 'test_helper'

class GradeTest < ActiveSupport::TestCase
  before do
    @grade = Grade.new subject: users(:dexter), grader: users(:admin),
        metric: assignment_metrics(:ps1_p1), course: courses(:main), score: 3.0
  end

  let(:grade) { grades(:dexter_assessment_overall) }

  it 'validates the setup grade' do
    assert @grade.valid?
  end

  it 'requires a metric' do
    @grade.metric = nil
    assert @grade.invalid?
  end

  it 'forbids a student from having multiple grades for a single metric' do
    @grade.metric = assignment_metrics(:assessment_overall)
    assert @grade.invalid?
  end

  it 'requires the grader to have permission to grade the metric' do
    authorized_graders = users(:robot, :main_grader, :main_staff, :admin)
    authorized_graders.each do |grader|
      @grade.grader = grader
      assert @grade.valid?
    end

    @grade.grader = users(:dexter)
    assert @grade.invalid?
  end

  it 'requires a course' do
    @grade.course = nil
    assert @grade.invalid?
  end

  it "requires that the course matches the metric's course" do
    @grade.course = courses(:not_main)
    assert @grade.invalid?
  end

  it 'requires a subject' do
    @grade.subject = nil
    assert @grade.invalid?
  end

  it 'requires a grader' do
    @grade.grader = nil
    assert @grade.invalid?
  end

  it 'requires a numeric score' do
    invalid_scores = ['string', '1string']
    invalid_scores.each do |score|
      @grade.score = score
      assert @grade.invalid?
    end

    valid_scores = [1, 1.1111, '1', '1.1']
    valid_scores.each do |score|
      @grade.score = score
      assert @grade.valid?
    end
  end

  it 'destroys dependent records' do
    assert_not_nil grade.comment

    grade.destroy

    assert_nil GradeComment.find_by(grade: grade)
  end

  describe '#users' do
    describe 'individual student grades' do
      it 'returns an array containing the student' do
        assert_equal [users(:dexter)], grade.users
      end
    end

    describe 'team grades' do
      it 'returns an array containing the team members' do
        assert_equal users(:admin, :dexter).to_set,
            grades(:awesome_ps1_p1).users.to_set
      end
    end
  end
end
