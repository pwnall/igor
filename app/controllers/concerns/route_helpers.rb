# Custom URL helper methods.
module RouteHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :deliverable_panel_path
    helper_method :deliverable_panel_url
    helper_method :deliverable_panel_id
    helper_method :exam_session_panel_url
  end

  # The student submission dashboard path, opened to the deliverable's tab.
  def deliverable_panel_path(deliverable)
    assignment_url(deliverable.assignment, course_id: deliverable.course,
        anchor: deliverable_panel_id(deliverable))
  end
  # The student submission dashboard URL, opened to the deliverable's tab.
  def deliverable_panel_url(deliverable)
    assignment_path(deliverable.assignment, course_id: deliverable.course,
        anchor: deliverable_panel_id(deliverable))
  end
  # The URL hash used to identify the given deliverable's tab.
  def deliverable_panel_id(deliverable)
    "deliverable-panel-#{deliverable.to_param}"
  end

  # The student submission dashboard URL, opened to the exam check-in tab.
  def exam_session_panel_url(exam_session)
    assignment_url(exam_session.assignment, course_id: exam_session.course,
        anchor: 'exam-sessions-panel')
  end
end
