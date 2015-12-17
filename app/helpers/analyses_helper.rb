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

  # The PwnFx identifier for refreshing the status of an analysis.
  def analysis_refresh_pwnfx_id(analysis)
    "analysis-status-#{analysis.to_param}"
  end

  # A link to the given analysis.
  def analysis_status_tag(analysis)
    status = analysis ? analysis.status : :analyzer_bug
    data_options = { tooltip: true, disable_hover: false }
    pwnfx_id = analysis_refresh_pwnfx_id analysis
    if analysis.status_will_change?
      data_options.merge! pwnfx_delayed: pwnfx_id, pwnfx_delayed_method: 'GET',
          pwnfx_delayed_url: refresh_analysis_path(analysis,
          course_id: analysis.course), pwnfx_delayed_ms: 5000,
          pwnfx_delayed_scope: pwnfx_id
    end
    icon_tag = content_tag :span, data: data_options,
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
