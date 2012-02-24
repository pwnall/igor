class DeliverablesController < ApplicationController
  before_filter :authenticated_as_admin
  
  # POST /deliverables/1/reanalyze
  def reanalyze
    deliverable = Deliverable.find params[:id], include: :assignment
    deliverable.submissions.includes(:analysis).each do |submission|
      submission.queue_analysis true
    end
    
    redirect_to dashboard_assignment_url(deliverable.assignment),
        notice: "All submissions for #{deliverable.name} queued for analysis"
  end
end
