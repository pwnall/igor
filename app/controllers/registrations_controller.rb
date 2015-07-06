class RegistrationsController < ApplicationController
  before_action :set_registration, only: [:show, :edit, :update]
  before_action :authenticated_as_user, only: [:show, :new, :create, :edit,
                                               :update]
  before_action :authenticated_as_admin,
                except: [:show, :new, :create, :edit, :update]

  # GET /registrations
  def index
    @course = Course.main
    @prerequisites = @course.prerequisites
    @registrations = @course.registrations
    @staff = @course.staff

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /registrations/1
  def show
    return bounce_user unless @registration.can_edit?(current_user)
    @registration.build_prerequisite_answers

    if @registration.can_edit?(current_user) and
        @registration.course.has_recitations?
      set_recitation_conflicts_for @registration
      set_time_slots_for @registration
    else
      @recitation_conflicts = nil
    end

    respond_to do |format|
      format.html
    end
  end

  # GET /registrations/new
  def new
    course = Course.main
    # Keep registration instance from #create to show validation error messages. 
    @registration ||= Registration.new user: current_user, course: course
    @registration.build_prerequisite_answers
    @recitation_conflicts = {}
    set_time_slots_for @registration

    # An explicit render is necessary when creating fails validations.
    render :new
  end

  # GET /registrations/1/edit
  def edit
    return bounce_user unless @registration.can_edit?(current_user)
    @registration.build_prerequisite_answers

    set_recitation_conflicts_for @registration
    set_time_slots_for @registration

    # An explicit render is necessary when updating fails validations.
    render :edit
  end

  # POST /registrations
  def create
    @registration = Registration.new registration_params
    @registration.user = current_user
    @registration.course = Course.main

    respond_to do |format|
      if @registration.save
        format.html do
          redirect_to root_url, notice:
              "You are now registered for #{@registration.course.number}."
        end
      else
        format.html { new }
      end
    end
  end

  # PUT /registrations/1
  def update
    return bounce_user unless @registration.can_edit?(current_user)

    respond_to do |format|
      if @registration.update registration_params
        format.html do
          redirect_to @registration, notice:
              "#{@registration.course.number} registration info updated."
        end
      else
        format.html { edit }
      end
    end
  end

  # XHR PATCH /registrations/1/restricted
  def restricted
    @registration = Registration.find params[:id]

    respond_to do |format|
      if @registration.update_attributes restricted_registration_params
        format.js { head :ok }
      else
        format.js { head :not_acceptable }
      end
    end
  end

  def set_registration
    @registration = Registration.find params[:id]
  end
  private :set_registration

  def set_recitation_conflicts_for(registration)
    @recitation_conflicts = registration.recitation_conflicts.
        index_by &:time_slot_id
  end
  private :set_recitation_conflicts_for

  def set_time_slots_for(registration)
    @time_slots = registration.course.time_slots_by_period
    @time_slot_periods = @time_slots.keys.sort!
    @time_slot_days = registration.course.days_with_time_slots
  end
  private :set_time_slots_for

  def registration_params
    return {} unless params[:registration]

    params.require(:registration).permit :for_credit, :allows_publishing,
        prerequisite_answers_attributes: [:took_course, :prerequisite_id,
                                          :waiver_answer, :id],
        recitation_conflicts_attributes: [:class_name, :time_slot_id, :id]
  end
  private :registration_params

  def restricted_registration_params
    params.require(:registration).permit :for_credit, :allows_publishing,
        :recitation_section_id,
        prerequisite_answers_attributes: [:took_course, :prerequisite_id,
                                          :waiver_answer]
  end
  private :registration_params
end
