class RecitationPartitionsController < ApplicationController
  before_filter :authenticated_as_user, only: [:new, :create, :edit, :update,
                                               :new_or_edit]
  before_filter :authenticated_as_admin, only: [:index, :show, :destroy]

  # GET /recitation_partition
  def index
    @partitions = RecitationPartition.all
    respond_to do |format|
      format.html
    end
  end

  # GET /recitation_partition/1
  def show
    @partition = RecitationPartition.where(id: params[:id]).
                                     includes(:recitation_assignments).first!
    respond_to do |format|
      format.html
    end
  end

  # DELETE /recitation_partitions/1
  def destroy
    @partition = RecitationPartition.find(params[:id])
    @partition.destroy

    respond_to do |format|
      flash[:notice] = "Assignment partition has been deleted"
      format.html { redirect_to recitation_partitions_url }
    end
  end

  # POST /recitation_partitions/1
  def implement
    @partition = RecitationPartition.find(params[:id])

    @partition.recitation_assignments.each do |assignment|
      registration = assignment.user.registration
      registration.recitation_section = assignment.recitation_section
      registration.save!
    end

    respond_to do |format|
      flash[:notice] = "Recitation sections updated"
      format.html { redirect_to recitation_partitions_url }
    end
  end
end
