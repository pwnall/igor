require 'test_helper'

class AssignmentMetricTest < ActiveSupport::TestCase
  before do
    @metric = AssignmentMetric.new assignment: assignments(:ps1), name: 'x',
        max_score: 1, weight: 1
  end

  let(:metric) { assignment_metrics(:ps1_p1) }

  it 'validates the setup metric' do
    assert @metric.valid?, @metric.errors.full_messages
  end

  it 'requires an assignment' do
    @metric.assignment = nil
    assert @metric.invalid?
  end

  it 'requires a name' do
    @metric.name = nil
    assert @metric.invalid?
  end

  it 'rejects lengthy names' do
    @metric.name = 'm' * 65
    assert @metric.invalid?
  end

  it 'forbids metrics for the same assignment from sharing names' do
    assert_equal @metric.assignment, metric.assignment
    @metric.name = metric.name
    assert @metric.invalid?
  end

  it 'requires a weight' do
    @metric.weight = nil
    assert @metric.invalid?
  end

  it 'accepts a weight of 0' do
    @metric.weight = 0
    assert @metric.valid?
  end

  it 'rejects negative weights' do
    @metric.weight = -1
    assert @metric.invalid?
  end

  it 'requires a maximum score' do
    @metric.max_score = nil
    assert @metric.invalid?
  end

  it 'rejects negative maximum scores' do
    @metric.max_score = -1
    assert @metric.invalid?
  end

  describe '#grade_for' do
    it 'returns an existing grade' do
      graded_metric = assignment_metrics(:assessment_overall)
      assert graded_metric.grades.find_by(subject: users(:dexter))

      grade = graded_metric.grade_for users(:dexter)
      assert_equal 70, grade.score
      assert_equal false, grade.new_record?
    end

    it 'returns a new grade if one does not exist' do
      ungraded_metric = assignment_metrics(:assessment_quality)
      assert_nil ungraded_metric.grades.find_by(subject: users(:dexter))

      grade = ungraded_metric.grade_for users(:dexter)
      assert_nil grade.score
      assert_equal true, grade.new_record?
    end
  end
end
