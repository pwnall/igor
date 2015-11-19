module AnalysesHelper
  STATUS_COLOR_CLASS = {
    ok: 'success',
    queued: 'info',
    running: 'info',
    analyzer_bug: 'secondary',
    limit_exceeded: 'alert',
    crashed: 'alert',
    wrong: 'alert'
  }

  # User-friendly text for an analysis' status property.
  def analysis_status_text(analysis)
    return 'No automated feedback' if analysis.nil?

    case analysis.status
    when :analyzer_bug
      'No automated feedback'
    when :queued
      'Queued'
    when :running
      'Running'
    when :limit_exceeded
      'Limit Exceeded'
    when :crashed
      'Crashed'
    when :wrong
      'Wrong Answer'
    when :ok
      'OK'
    end
  end

  # A link to the given analysis.
  def analysis_status_tag(analysis)
    status = analysis ? analysis.status : :analyzer_bug
    icon_tag = content_tag :span, data: { tooltip: true, disable_hover: false },
        class: "has-tip top #{STATUS_COLOR_CLASS[status]} analysis-status-icon",
        title: analysis_status_text(analysis) do
      analysis_status_icon_tag analysis
    end

    if analysis
      link_to icon_tag, analysis_path(analysis, course_id: analysis.course),
          class: 'contains-tooltip'
    else
      icon_tag
    end
  end

  # A badge that illustrates the status of the given analysis.
  def analysis_status_badge_tag(analysis)
    status = analysis ? analysis.status : :analyzer_bug
    content_tag :span, class: "#{STATUS_COLOR_CLASS[status]} badge" do
      analysis_status_icon_tag analysis
    end
  end

  # An HTML class describing whether the analysis is for a promoted submission.
  def analyzed_submission_class(analysis)
    if analysis.submission.selected_for_grading?
      'main-submission'
    else
      'analyzed-submission'
    end
  end
end
