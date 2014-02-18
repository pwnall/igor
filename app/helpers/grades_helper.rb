module GradesHelper
  # True if any of the given grades has a comment)
  def grades_have_comments(grades)
    grades.any? { |grade| grade && grade.comment }
  end

  def grade_comment_text(grade)
    grade.comment ? grade.comment.comment : nil
  end

  # Sums up all the scores in an array of grades.
  def grades_sum(grades)
    grades.map { |grade| (grade && grade.score) || 0 }.sum
  end

  # Sums up the maxium scores in an array of metrics.
  def metrics_max_score(metrics)
    metrics.map(&:max_score).sum
  end

  # The text shown to a student looking at a grade.
  def grade_display_text(grade)
    (grade && grade.score) || 'N'
  end
end
