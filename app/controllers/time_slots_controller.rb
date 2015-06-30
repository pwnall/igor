class TimeSlotsController < ApplicationController
  before_action :authenticated_as_admin

  # GET /time_slots
  def index
    @course = Course.main
    @time_slots = @course.time_slots
  end

  # POST /time_slots
  def create
    @course = Course.main
    @time_slot = @course.time_slots.build time_slot_params

    respond_to do |format|
      if @time_slot.save
        format.html do
          redirect_to time_slots_path, notice: 'Time slot successfully created.'
        end
      else
        format.html { render :index }
      end
    end
  end

  # DELETE /time_slots/1
  def destroy
    @time_slot = TimeSlot.find params[:id]
    @time_slot.destroy

    respond_to do |format|
      notice = 'Time slot was removed.'
      format.html { redirect_to time_slots_path, notice: notice }
    end
  end

  def time_slot_params
    params.require(:time_slot).permit :start_time, :end_time, :day
  end
end
