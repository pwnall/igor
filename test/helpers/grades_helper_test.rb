require 'test_helper'

class GradesHelperTest < ActionView::TestCase
  include GradesHelper

  let(:metric) { assignment_metrics(:assessment_overall) }

  describe '#grade_score_text' do
    it 'returns a numeric score if a grade can be found' do
      assert_not_nil metric.grades.find_by subject: users(:dexter)
      assert_equal 80.0, grade_score_text(metric, users(:dexter))
    end

    it 'returns nil if no grade can be found' do
      assert_nil metric.grades.find_by subject: users(:deedee)
      assert_nil grade_score_text(metric, users(:deedee))
    end
  end

  describe '#grade_comment_text' do
    it 'returns a string if a comment can be found' do
      assert_not_nil metric.comments.find_by subject: users(:dexter)
      assert_equal 'Good job.', grade_comment_text(metric, users(:dexter))
    end

    it 'returns nil if no comment can be found' do
      assert_nil metric.comments.find_by subject: users(:solo)
      assert_nil grade_comment_text(metric, users(:solo))
    end
  end
end
