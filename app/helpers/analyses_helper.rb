module AnalysesHelper
  # User-friendly text for an analysis' status property.
  def analysis_status_text(analysis)
    return 'No automated feedback' if analysis.nil?
    
    case analysis.status
    when :no_analyzer
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
end
