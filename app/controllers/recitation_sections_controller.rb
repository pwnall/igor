class RecitationSectionsController < ApplicationController
  before_action :set_recitation_section, only: [:show, :edit, :update, :destroy]
  before_action :authenticated_as_admin

  # GET /recitation_sections
  def index
    @recitation_sections = RecitationSection.includes(:leader).all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /recitation_sections/1
  def show
    new_edit
  end

  # GET /recitation_sections/new
  def new
    @recitation_section = RecitationSection.new course: Course.main,
        serial: 1 + RecitationSection.count
  end

  # GET /recitation_sections/1/edit
  def edit
  end

  # POST /recitation_sections
  def create
    @recitation_section = RecitationSection.new recitation_section_params
    @recitation_section.course = Course.main

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

  # PUT /recitation_sections/1
  def update
    respond_to do |format|
      if @recitation_section.update_attributes recitation_section_params
        format.html do
          redirect_to recitation_sections_url, notice:
              "Recitation section R#{@recitation_section.serial} updated."
        end
      else
        format.html { render action: :edit }
      end
    end
  end


  # POST /recitation_sections/autoassign
  def autoassign
    RecitationAssigner.delay.assign_and_email current_user, Course.main,
                                              root_url

    respond_to do |format|
      format.html do
        redirect_to recitation_sections_url, notice:
            'Started recitation assignment. Email will arrive shortly.'
      end
    end
  end

  # DELETE /recitation_sections/1
  def destroy
    @recitation_section.destroy

    respond_to do |format|
      format.html { redirect_to recitation_sections_url }
    end
  end

  def set_recitation_section
    @recitation_section = RecitationSection.find params[:id]
  end
  private :set_recitation_section

  def recitation_section_params
    params.require(:recitation_section).permit :serial, :leader_id, :time,
        :location
  end
  private :recitation_section_params
end
