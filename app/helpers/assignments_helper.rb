module AssignmentsHelper
  # TODO(spark008): Adjust for multiple submissions per student.
  def submissions_progress_tag(assignment_or_deliverable)
    expected = assignment_or_deliverable.expected_submissions
    total = assignment_or_deliverable.submissions.count
    percent = '%.2f' % ((total * 100) / expected.to_f)
    tag :progress, value: total, max: expected,
        title: "#{percent}% received (#{total} / #{expected})"
  end

  def grading_progress_tag(assignment_or_metric)
    expected = assignment_or_metric.expected_grades
    total = assignment_or_metric.grades.count
    percent = '%.2f' % ((total * 100) / expected.to_f)
    title = "#{percent}% (#{total} / #{expected})"

    content_tag(:span, class: 'meter-container') {
      content_tag :meter, title, value: total,
          low: expected - 1, max: expected
    } + content_tag(:span, title)
  end

  def grading_stats_tags(assignment_or_metric)
    if assignment_or_metric.respond_to? :metrics
      totals = assignment_or_metric.grades.includes(:subject).
          group_by(&:subject).map { |k, v| v.map(&:score).sum }
      avg = totals.sum.to_f / totals.length
    else
      avg = assignment_or_metric.grades.average(:score) || 0
    end
    max = assignment_or_metric.max_score || 0.0001
    percent = '%.2f' % ((avg * 100) / max.to_f)
    title = "#{percent}% (#{'%.2f' % avg} / #{max})"

    content_tag(:span, class: 'meter-container') {
      content_tag(:meter, title, min: 0, value: avg, max: max, title: title)
    } + content_tag(:span, title)
  end

  def grading_recitation_tags(assignment, recitation_section)
    avg = assignment.recitation_score recitation_section

    max = assignment.max_score || 0.0001
    percent = '%.2f' % ((avg * 100) / max.to_f)
    title = "#{percent}% (#{'%.2f' % avg} / #{max})"

    content_tag(:span, class: 'meter-container') {
      content_tag(:meter, title, min: 0, value: avg, max: max, title: title)
    } + content_tag(:span, title)

  end

  # The confirmation message when unpublishing an assignment.
  def unpublish_confirmation(assignment)
    if assignment.grades_published? && assignment.grades.count > 0
      'Any grades for this assignment will also be pulled. Continue?'
    end
  end

  # The confirmation message when publishing grades for the given assignment.
  #
  # A message is shown only if the assignment has unreleased deliverables.
  def publish_grades_confirmation(assignment)
    if !assignment.published? && assignment.deliverables.count > 0
      'The deliverables for this assignment will also be released. Continue?'
    end
  end
end
