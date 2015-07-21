class RecitationPartitionsController < ApplicationController
  before_action :authenticated_as_course_editor

  # GET /6.006/recitation_partition
  def index
    @partitions = current_course.recitation_partitions
    respond_to do |format|
      format.html
    end
  end

  # GET /6.006/recitation_partition/1
  def show
    @partition = current_course.recitation_partitions.where(id: params[:id]).
                                includes(:recitation_assignments).first!
    respond_to do |format|
      format.html
    end
  end

  # DELETE /6.006/recitation_partitions/1
  def destroy
    @partition = current_course.recitation_partitions.find params[:id]
    @partition.destroy

    respond_to do |format|
      format.html do
        redirect_to recitation_partitions_url(course_id: @partition.course),
            notice: 'Assignment partition deleted'
      end
    end
  end

  # POST /6.006/recitation_partitions/1/implement
  def implement
    @partition = current_course.recitation_partitions.find params[:id]
    course = @partition.course

    @partition.recitation_assignments.each do |assignment|
      registration = assignment.user.registration_for(course)
      registration.recitation_section = assignment.recitation_section
      registration.save!
    end

    respond_to do |format|
      format.html do
        redirect_to recitation_sections_url(course_id: @partition.course),
            notice: 'Recitation sections updated'
      end
    end
  end
end
