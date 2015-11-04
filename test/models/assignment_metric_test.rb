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
      graded_metric = overall_metric
      assert graded_metric.grades.find_by(subject: users(:dexter))

      grade = graded_metric.grade_for users(:dexter)
      assert_equal 80, grade.score
      assert_equal false, grade.new_record?
    end

    it 'returns a new grade if one does not exist' do
      ungraded_metric = quality_metric
      assert_nil ungraded_metric.grades.find_by(subject: users(:dexter))

      grade = ungraded_metric.grade_for users(:dexter)
      assert_nil grade.score
      assert_equal true, grade.new_record?
    end
  end

  describe '#grade_for_recitation' do
    let(:dexter_solo_section) { recitation_sections(:r01) }
    let(:deedee_section) { recitation_sections(:r02) }

    it 'returns the average score for students in the given recitation only' do
      assert_equal 6, quality_metric.grade_for_recitation(deedee_section)
    end

    it 'returns 0 if none of the students in the recitation has a grade' do
      assert_empty Grade.where(subject: deedee_section, metric: overall_metric)
      assert_equal 0, overall_metric.grade_for_recitation(deedee_section)
    end

    it 'accounts only for students who have a grade' do
      assert_not_equal Grade.where(subject: dexter_solo_section,
          metric: overall_metric).count, dexter_solo_section.users.count
      assert_equal 10, quality_metric.grade_for_recitation(dexter_solo_section)
    end
  end

  describe 'score calculations' do
    describe 'AverageScore concern' do
      describe '#average_score_percentage' do
        describe 'no grades have been issued yet' do
          before { assert_empty gradeless_metric.grades }

          it 'returns 0' do
            assert_equal 0, gradeless_metric.average_score_percentage
          end
        end

        describe 'the metric has a non-zero weight' do
          before { assert_not_equal 0, overall_metric.weight }

          it 'returns the average non-weighted score on the metric' do
            # ((80 + 10) / 2.0)*100 / 100 = 45
            assert_equal 45, overall_metric.average_score_percentage
          end
        end

        describe 'the metric has a weight of 0' do
          before { assert_equal 0, quality_metric.weight }

          it 'returns the average non-weighted score on the metric' do
            # ((10 + 6) / 2.0)*100 / 10 = 80
            assert_equal 80, quality_metric.average_score_percentage
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
        before { assert_empty gradeless_metric.grades }

        it 'returns 0' do
          assert_equal 0, gradeless_metric.average_score
        end
      end

      describe 'the metric has a non-zero weight' do
        before { assert_not_equal 0, overall_metric.weight }

        it 'returns the average unweighted score on the metric' do
          # (80 + 10) / 2.0 = 45
          assert_equal 45, overall_metric.average_score
        end
      end

      describe 'the metric has a weight of 0' do
        before { assert_equal 0, quality_metric.weight }

        it 'returns the average unweighted score on the metric' do
          # (10 + 6) / 2.0 = 8
          assert_equal 8, quality_metric.average_score
        end
      end
    end
  end
end
