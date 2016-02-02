class RecitationSectionsController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_course_editor
  before_action :set_recitation_section, only: [:edit, :update, :destroy]

  # GET /6.006/recitation_sections
  def index
    @recitation_sections = current_course.recitation_sections.
        includes(:leader).all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /6.006/recitation_sections/new
  def new
    @recitation_section = RecitationSection.new course: current_course,
        serial: 1 + current_course.recitation_sections.count
  end

  # GET /6.006/recitation_sections/1/edit
  def edit
  end

  # POST /6.006/recitation_sections
  def create
    @recitation_section = RecitationSection.new recitation_section_params
    @recitation_section.course = current_course

    respond_to do |format|
      if @recitation_section.save
        format.html do
          redirect_to recitation_sections_url, notice:
              "Recitation section R#{@recitation_section.serial} created."
        end
      else
        format.html { render action: :new }
      end
    end
  end

  # PUT /6.006/recitation_sections/1
  def update
    respond_to do |format|
      if @recitation_section.update recitation_section_params
        format.html do
          redirect_to recitation_sections_url, notice:
              "Recitation section R#{@recitation_section.serial} updated."
        end
      else
        format.html { render action: :edit }
      end
    end
  end

  # POST /6.006/recitation_sections/autoassign
  def autoassign
    RecitationAssignerJob.perform_later current_course, current_user, root_url

    respond_to do |format|
      format.html do
        redirect_to recitation_sections_url, notice:
            'Started recitation assignment. Email will arrive shortly.'
      end
    end
  end

  # DELETE /6.006/recitation_sections/1
  def destroy
    @recitation_section.destroy

    respond_to do |format|
      format.html do
        redirect_to recitation_sections_url(
            course_id: @recitation_section.course)
      end
    end
  end

  def set_recitation_section
    @recitation_section = current_course.recitation_sections.find params[:id]
  end
  private :set_recitation_section

  def recitation_section_params
    params.require(:recitation_section).permit :serial, :leader_id,
        { time_slot_ids: [] }, :location
  end
  private :recitation_section_params
end
