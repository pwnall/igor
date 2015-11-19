class TimeSlotsController < ApplicationController
  before_action :authenticated_as_course_editor

  # GET /6.006/time_slots
  def index
    @time_slots = current_course.time_slots.order(:day, :starts_at, :ends_at)
    @time_slot = TimeSlot.new course: current_course
  end

  # POST /6.006/time_slots
  def create
    @time_slot = current_course.time_slots.build time_slot_params

    respond_to do |format|
      if @time_slot.save
        format.html do
          redirect_to time_slots_url(course_id: @time_slot.course),
              notice: 'Time slot successfully created.'
        end
      else
        format.html do
          @time_slots = current_course.time_slots.reload
          render :index
        end
      end
    end
  end

  # DELETE /6.006/time_slots/1
  def destroy
    @time_slot = TimeSlot.find params[:id]
    @time_slot.destroy

    respond_to do |format|
      format.html do
        redirect_to time_slots_url(course_id: @time_slot.course),
            notice: 'Time slot removed.'
      end
    end
  end

  def time_slot_params
    params.require(:time_slot).permit :start_time, :end_time, :day
  end
end
