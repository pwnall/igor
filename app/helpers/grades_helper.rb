module GradesHelper
  # Option tags for the assignments in the given course that will be graded.
  def gradeable_assignment_options(course, selected)
    assignments = course.assignments.by_deadline
    options_from_collection_for_select assignments, :id, :name, selected.id
  end

  # The weighted sum of all the scores in an array of grades.
  def grades_sum(grades)
    grades.map { |grade| grade ? grade.score * grade.metric.weight : 0 }.sum
  end

  # The text shown to a student looking at a grade.
  def grade_display_text(grade)
    (grade && grade.score) || 'N'
  end
end
