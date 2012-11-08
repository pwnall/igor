class RecitationAssignmentProposalsController < ApplicationController
  before_filter :authenticated_as_user, :only => [:new, :create, :edit, :update, :new_or_edit]
  before_filter :authenticated_as_admin, :only => [:index, :show, :destroy]

  # GET /recitation_assignment_proposal
  def index
    @proposals = RecitationAssignmentProposal.all
    respond_to do |format|
      format.html
    end 
  end

  # GET /recitation_assignment_proposal/1
  def show
    @proposal = RecitationAssignmentProposal.find(params[:id], include: :recitation_student_assignments)
    respond_to do |format|
      format.html
    end
  end

  # DELETE /recitation_assignment_proposals/1
  def destroy
    @proposal = RecitationAssignmentProposal.find(params[:id])
    @proposal.destroy

    respond_to do |format|
      flash[:notice] = "Assignment proposal has been deleted"
      format.html { redirect_to(recitation_assignment_proposals_url) }
    end
  end

  # POST /recitation_assignment_proposals/1
  def implement
    @proposal = RecitationAssignmentProposal.find(params[:id])

    @proposal.recitation_student_assignments.each do |rsa|
      if ! rsa.has_conflict
        rsa.user.registration.recitation_section = rsa.recitation_section
        rsa.user.registration.save
      end
    end

    respond_to do |format|
      flash[:notice] = "Recitation sections updated"
      format.html { redirect_to :back }
    end
  end

end
