require 'test_helper'

class AssignmentsHelperTest < ActionView::TestCase
  include AssignmentsHelper

  let(:unreleased_exam) { assignments(:main_exam) }
  let(:unreleased_assignment) { assignments(:ps3) }
  let(:released_assignment) { assignments(:ps1) }
  let(:grades_unreleased_assignment) { assignments(:ps2) }
  let(:many_metrics_assignment) { assignments(:assessment) }

  let(:gradeless_metric) { assignment_metrics(:ps2_p1) }
  let(:weighted_metric) { assignment_metrics(:assessment_overall) }
  let(:checkoff_metric) { assignment_metrics(:assessment_quality) }

  describe '#average_score_stats' do
    describe 'measuring an Assignment' do
      describe 'assignment has no metrics' do
        before { assert_empty unreleased_assignment.metrics }

        it 'displays the percentage and fraction with dashes' do
          assert_equal '-% (- / -)', average_score_stats(unreleased_assignment)
        end
      end

      describe 'assignment has metrics, but no grades issued' do
        before do
          assert_not_empty grades_unreleased_assignment.metrics
          assert_empty grades_unreleased_assignment.grades
        end

        it 'displays a percentage and fraction equivalent to 0' do
          assert_equal '0.00% (0.00 / 100.00)',
              average_score_stats(grades_unreleased_assignment)
        end
      end

      describe 'grades have been issued' do
        before { assert_not_empty many_metrics_assignment.grades }

        it 'displays the average score as a percentage and as a fraction' do
          assert_equal '30.00% (30.00 / 100.00)',
              average_score_stats(many_metrics_assignment)
        end
      end
    end

    describe 'measuring an AssignmentMetric' do
      describe 'no grades have been issued yet' do
        before { assert_empty gradeless_metric.grades }

        it 'displays a percentage and fraction equivalent to 0' do
          assert_equal '0.00% (0.00 / 10.00)', average_score_stats(gradeless_metric)
        end
      end

      describe 'the metric has a non-zero weight' do
        before { assert_not_equal 0, weighted_metric.weight }

        it 'displays the average score as a percentage and as a fraction' do
          assert_equal '45.00% (45.00 / 100.00)',
              average_score_stats(weighted_metric)
        end
      end

      describe 'the metric has a weight of 0' do
        before { assert_equal 0, checkoff_metric.weight }

        it 'displays the average score as a percentage and as a fraction' do
          assert_equal '80.00% (8.00 / 10.00)',
              average_score_stats(checkoff_metric)
        end
      end
    end
  end

  describe '#unpublish_confirmation' do
    describe 'assignment released, grades unpublished' do
      before do
        @assignment = grades_unreleased_assignment
        assert_equal true, grades_unreleased_assignment.published?
        assert_equal false, grades_unreleased_assignment.grades_published?
      end

      it 'returns nil' do
        assert_nil unpublish_confirmation(@assignment)
      end
    end

    describe 'assignment released, grades published' do
      before do
        @assignment = released_assignment
        assert_equal true, released_assignment.published?
        assert_equal true, released_assignment.grades_published?
      end

      it 'returns a confirmation message' do
        assert_match /Continue\?/, unpublish_confirmation(@assignment)
      end
    end
  end

  describe '#publish_grades_confirmation' do
    describe 'assignment released, grades unpublished' do
      before do
        @assignment = grades_unreleased_assignment
        assert_equal true, grades_unreleased_assignment.published?
        assert_equal false, grades_unreleased_assignment.grades_published?
      end

      it 'returns nil' do
        assert_nil unpublish_confirmation(@assignment)
      end
    end

    describe 'assignment unreleased, no deliverables' do
      before do
        @assignment = unreleased_exam
        assert_equal false, unreleased_exam.published?
        assert_equal false, unreleased_exam.grades_published?
        assert_empty unreleased_exam.deliverables
      end

      it 'returns nil' do
        assert_nil publish_grades_confirmation(@assignment)
      end
    end

    describe 'assignment unreleased, deliverables exist' do
      before do
        @assignment = unreleased_assignment
        assert_equal false, unreleased_assignment.published?
        assert_equal false, unreleased_assignment.grades_published?
        assert_not_empty unreleased_assignment.deliverables
      end

      it 'returns a confirmation message' do
        assert_match /Continue\?/, publish_grades_confirmation(@assignment)
      end
    end
  end
end
