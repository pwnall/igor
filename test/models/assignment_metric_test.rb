require 'test_helper'

class AssignmentMetricTest < ActiveSupport::TestCase
  before do
    @metric = AssignmentMetric.new assignment: assignments(:assessment),
        name: 'Effort', max_score: 10, weight: 2
  end

  let(:gradeless_metric) { assignment_metrics(:ps3_p1) }
  let(:overall_metric) { assignment_metrics(:assessment_overall) }
  let(:quality_metric) { assignment_metrics(:assessment_quality) }

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
    assert_equal @metric.assignment, overall_metric.assignment
    @metric.name = overall_metric.name
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
      ungraded_metric = assignment_metrics(:ps3_p1)
      assert_nil ungraded_metric.grades.find_by(subject: users(:dexter))

      grade = ungraded_metric.grade_for users(:dexter)
      assert_nil grade.score
      assert_equal true, grade.new_record?
    end
  end

  describe 'score calculations' do
    describe 'AverageScore concern' do
      describe '#average_score_percentage' do
        describe 'no grades have been issued yet' do
          let(:metric) { assignment_metrics(:ps3_p1) }
          before { assert_empty metric.grades }

          it 'returns 0' do
            assert_equal 0, metric.average_score_percentage
          end
        end

        describe 'the metric has a non-zero weight' do
          let(:metric) { assignment_metrics(:assessment_overall) }
          before { assert_not_equal 0, metric.weight }

          it 'returns the average non-weighted score on the metric' do
            # ((70 + 100 + 10) / 3.0) * 100 / 100 = 60
            assert_equal 60, metric.average_score_percentage
          end
        end

        describe 'the metric has a weight of 0' do
          let(:metric) { assignment_metrics(:assessment_quality) }
          before { assert_equal 0, metric.weight }

          it 'returns the average non-weighted score on the metric' do
            # ((8.6 + 10 + 3) / 3.0) * 100 / 10 = 72
            assert_equal 72, metric.average_score_percentage
          end
        end
      end
    end

    describe '#weighted_max_score' do
      it 'returns the weighted maximum score' do
        assert_equal 20, @metric.weighted_max_score  # 10 * 2
      end
    end

    describe '#average_score' do
      describe 'no grades have been issued yet' do
        let(:metric) { assignment_metrics(:ps3_p1) }
        before { assert_empty metric.grades }

        it 'returns 0' do
          assert_equal 0, metric.average_score
        end
      end

      describe 'the metric has a non-zero weight' do
        let(:metric) { assignment_metrics(:assessment_overall) }
        before { assert_not_equal 0, metric.weight }

        it 'returns the average unweighted score on the metric' do
          # (70 + 100 + 10) / 3.0 = 60
          assert_equal 60, metric.average_score
        end
      end

      describe 'the metric has a weight of 0' do
        let(:metric) { assignment_metrics(:assessment_quality) }
        before { assert_equal 0, metric.weight }

        it 'returns the average unweighted score on the metric' do
          # (8.6 + 10 + 3) / 3.0 = 7.2
          assert_equal 7.2, metric.average_score
        end
      end
    end
  end
end
