class DeliverablesController < ApplicationController
  before_action :authenticated_as_course_editor

  # POST /6.006/deliverables/1/reanalyze
  def reanalyze
    @deliverable = current_course.deliverables.where(id: params[:id]).
        includes(:assignment).first!
    @deliverable.reanalyze_submissions

    redirect_to dashboard_assignment_url(@deliverable.assignment,
                                         course_id: @deliverable.course),
        notice: "All submissions for #{@deliverable.name} queued for analysis"
  end

  # XHR GET /6.006/deliverables/1/submission_dashboard
  def submission_dashboard
    @deliverable = current_course.deliverables.where(id: params[:id]).
        includes(:assignment).first!
    render layout: false if request.xhr?
  end
end
