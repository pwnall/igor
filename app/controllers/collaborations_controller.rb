class CollaborationsController < ApplicationController
  include SidebarLayout

  before_action :set_current_course
  before_action :authenticated_as_user

  # POST /6.006/collaborations
  def create
    @collaboration = Collaboration.new collaboration_params
    @collaboration.submission = Submission.find params[:submission_id]
    return bounce_user unless @collaboration.submission.can_edit? current_user

    respond_to do |format|
      if @collaboration.save
        format.html do
          redirect_to deliverable_panel_url(@collaboration.submission.deliverable),
              notice: "#{@collaboration.collaborator.email} was added as a
              collaborator to a submission for
              #{@collaboration.assignment.name}."
        end
      else
        format.html do
          @assignment = @collaboration.assignment
          render 'assignments/show'
        end
      end
    end
  end

  # DELETE /6.006/collaborations/1
  def destroy
    @collaboration = Collaboration.find params[:id]
    return bounce_user unless @collaboration.submission.can_edit? current_user
    @collaboration.destroy

    respond_to do |format|
      format.html do
        redirect_to deliverable_panel_url(@collaboration.submission.deliverable),
            notice: "Collaborator #{@collaboration.collaborator.email} was
            removed from a submission for #{@collaboration.assignment.name}."
      end
    end
  end

  def collaboration_params
    params.require(:collaboration).permit(:collaborator_email)
  end
  private :collaboration_params
end
