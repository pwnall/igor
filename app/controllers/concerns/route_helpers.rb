# Custom URL helper methods.
module RouteHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :deliverable_panel_path
    helper_method :deliverable_panel_url
    helper_method :deliverable_panel_id
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
end
