module GradesHelper
  # The score of the grade for the given metric and subject.
  def grade_score_text(metric, subject)
    grade = Grade.find_by metric: metric, subject: subject
    grade && grade.score
  end

  # The text of the comment for the given metric and subject.
  def grade_comment_text(metric, subject)
    comment = GradeComment.find_by metric: metric, subject: subject
    comment && comment.text
  end

  # The weighted sum of all the scores in an array of grades.
  def grades_sum(grades)
    grades.map { |grade| grade ? grade.score * grade.metric.weight : 0 }.sum
  end

  # THe weighted sum of the maximum scores in an array of metrics.
  def metrics_max_score(metrics)
    metrics.map { |metric| metric.max_score * metric.weight }.sum
  end

  # The text shown to a student looking at a grade.
  def grade_display_text(grade)
    (grade && grade.score) || 'N'
  end
end
