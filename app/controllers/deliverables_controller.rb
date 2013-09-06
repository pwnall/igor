class DeliverablesController < ApplicationController
  before_filter :authenticated_as_admin

  # POST /deliverables/1/reanalyze
  def reanalyze
    @deliverable = Deliverable.where(id: params[:id]).includes(:assignment).
                               first!
    @deliverable.reanalyze_submissions

    redirect_to dashboard_assignment_url(@deliverable.assignment),
        notice: "All submissions for #{@deliverable.name} queued for analysis"
  end

  # XHR GET /deliverables/1/submission_dashboard
  def submission_dashboard
    @deliverable = Deliverable.where(id: params[:id]).includes(:assignment).
                               first!
    render layout: false if request.xhr?
  end
end
