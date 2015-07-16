require 'test_helper'

class AssignmentMetricTest < ActiveSupport::TestCase
  before do
    @metric = AssignmentMetric.new assignment: assignments(:ps1), name: 'x',
        max_score: 1
  end

  let(:metric) { assignment_metrics(:ps1_p1) }

  it 'validates the setup metric' do
    assert @metric.valid?, @metric.errors.full_messages
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
