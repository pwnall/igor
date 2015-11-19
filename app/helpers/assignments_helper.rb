module AssignmentsHelper
  # The course-wide average score for the given assignment/metric as a fraction.
  #
  # @example An assignment with average score 5/10.
  #   <span class="score">5.00</span>/<span class="max-score">10.00</span>
  #
  # @example An assignment with no metrics.
  #   <span class="score">-</span>/<span class="max-score">-</span>
  #
  # @param [Assignment|AssignmentMetric] gradeable the assignment or metric
  #   whose average score we want
  # @param [RecitationSection] recitation_section optionally specify a
  #   recitation section to restrict scores to those of students in that section
  def average_score_fraction_tag(gradeable, recitation_section = nil)
    raw_average = if recitation_section
      gradeable.recitation_score recitation_section
    else
      gradeable.average_score
    end
    formatted_average = raw_average ? '%.2f' % raw_average : '-'
    score_tag = content_tag :span, formatted_average, class: 'score'

    raw_max = gradeable.max_score
    formatted_max = raw_max ? '%.2f' % raw_max : '-'
    max_score_tag = content_tag :span, formatted_max, class: 'max-score'

    safe_join [score_tag, '/', max_score_tag]
  end

  # The fraction of final grades awarded for the given assignment/metric.
  #
  # @example An assignment with 5 grades issued in a class of 10 students.
  #   <span class="current-count">5</span>/<span class="max-count">10</span>
  def grading_process_fraction_tag(gradeable)
    total = gradeable.grades.count
    total_tag = content_tag :span, total, class: 'current-count'

    expected = gradeable.expected_grades
    expected_tag = content_tag :span, expected, class: 'max-count'

    safe_join [total_tag, '/', expected_tag]
  end

  # The fraction of expected submissions for the given assignment/deliverable.
  #
  # @example An assignment that 5 out of 10 students have completed.
  #   <span class="current-count">5</span>/<span class="max-count">10</span>
  #
  # @param [Assignment|Deliverable] submittable the assignment or deliverable
  #   in question
  def submission_count_fraction_tag(submittable)
    if submittable.respond_to?(:deliverables) && submittable.deliverables.empty?
      total = '-'
      expected = '-'
    else
      total = submittable.submissions.select(:subject_id, :deliverable_id).
          group(:subject_id, :deliverable_id).length
      expected = submittable.expected_submissions
    end
    total_tag = content_tag :span, total, class: 'current-count'
    expected_tag = content_tag :span, expected, class: 'max-count'

    safe_join [total_tag, '/', expected_tag]
  end

  # A progress meter that shows the number of grades for this assignment/metric.
  #
  # A progress meter should not be shown for assignments that have no metrics
  # and/or for courses that have no students.
  def grading_progress_tag(gradeable)
    total = gradeable.grades.count
    expected = gradeable.expected_grades
    return '' unless expected > 0
    percentage = '%.2f%' % ((total * 100) / expected.to_f)
    progress_meter_tag percentage
  end

  # A progress meter that shows the average score on this assignment/metric.
  #
  # A progress meter should not be shown for assignments that have no metrics
  # and/or for courses that have no students.
  def average_score_meter_tag(gradeable)
    raw_percentage = gradeable.average_score_percentage
    return '' unless raw_percentage
    formatted_percentage = '%.2f%' % raw_percentage
    progress_meter_tag formatted_percentage
  end

  # A progress meter that shows the average score within the recitation section.
  #
  # A progress meter should not be shown for assignments that have no metrics
  # and/or for courses that have no students.
  #
  # @param [Assignment] assignment the assignment whose average score is shown
  # @param [RecitationSection] recitation_section the recitation section whose
  #   students' scores are being averaged
  def recitation_score_meter_tag(assignment, recitation_section)
    average_score = assignment.recitation_score recitation_section
    return '' unless average_score
    max_score = assignment.max_score
    percentage = '%.2f%' % (average_score * 100 / max_score.to_f)
    progress_meter_tag percentage
  end

  # A progress meter that shows the fraction of expected submissions.
  #
  # A progress meter should not be shown for assignments that have no metrics
  # and/or for courses that have no students.
  #
  # @param [Assignment|Deliverable] submittable the assignment or deliverable
  #   in question
  def submission_count_meter_tag(submittable)
    total = submittable.submissions.select(:subject_id, :deliverable_id).
        group(:subject_id, :deliverable_id).length
    expected = submittable.expected_submissions
    return '' unless expected > 0
    percentage = '%.2f%' % (total * 100 / expected.to_f)
    progress_meter_tag percentage
  end

  # A progress meter that displays the given percentage string.
  #
  # @param [String] formatted_percentage the percentage exactly as it should be
  #   displayed; must include the '%' sign. E.g., '25%'
  def progress_meter_tag(formatted_percentage)
    content_tag :div, class: 'progress' do
      content_tag :span, class: 'progress-meter',
          style: "width:#{formatted_percentage}" do
        content_tag :p, formatted_percentage, class: 'progress-meter-text'
      end
    end
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
