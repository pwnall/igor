module AssignmentsHelper
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
    avg = assignment_or_metric.grades.average(:score) || 0
    max = assignment_or_metric.max_score || 0.0001
    percent = '%.2f' % ((avg * 100) / max.to_f)
    title = "#{percent}% (#{'%.2f' % avg} / #{max})"
    
    content_tag(:span, class: 'meter-container') {
      content_tag(:meter, title, min: 0, value: avg, max: max, title: title)
    } + content_tag(:span, title)
  end
end
