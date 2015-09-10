class RegistrationsController < ApplicationController
  before_action :set_current_course
  before_action :set_registration, only: [:show, :edit, :update, :restricted]
  before_action :authenticated_as_user, only: [:show, :new, :create, :edit,
                                               :update]
  before_action :authenticated_as_course_editor,
                except: [:show, :new, :create, :edit, :update]

  # GET /6.006/registrations
  def index
    @prerequisites = current_course.prerequisites
    @registrations = current_course.registrations.by_user_name
    @staff = current_course.staff

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /6.006/registrations/1
  def show
    return bounce_user unless @registration.can_view?(current_user)
    @registration.build_prerequisite_answers

    if @registration.course.has_recitations?
      set_time_slots_for @registration
      set_recitation_conflicts_for @registration
    end

    respond_to do |format|
      format.html
    end
  end

  # GET /6.006/registrations/new
  def new
    # Keep registration instance from #create to show validation error messages.
    @registration ||= Registration.new user: current_user,
                                       course: current_course
    @registration.build_prerequisite_answers
    @recitation_conflicts = {}
    set_time_slots_for @registration

    # An explicit render is necessary when creating fails validations.
    render :new
  end

  # GET /6.006/registrations/1/edit
  def edit
    return bounce_user unless @registration.can_edit?(current_user)
    @registration.build_prerequisite_answers

    set_recitation_conflicts_for @registration
    set_time_slots_for @registration

    # An explicit render is necessary when updating fails validations.
    render :edit
  end

  # POST /6.006/registrations
  def create
    @registration = Registration.new registration_params
    @registration.user = current_user
    @registration.course = current_course

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

  # PUT /6.006/registrations/1
  def update
    return bounce_user unless @registration.can_edit?(current_user)

    respond_to do |format|
      if @registration.update registration_params
        format.html do
          redirect_to registration_url(@registration,
              course_id: @registration.course), notice:
              "#{@registration.course.number} registration info updated."
        end
      else
        format.html { edit }
      end
    end
  end

  # XHR PATCH /6.006/registrations/1/restricted
  def restricted
    respond_to do |format|
      if @registration.update_attributes restricted_registration_params
        format.js { head :ok }
      else
        format.js { head :not_acceptable }
      end
    end
  end

  def set_registration
    @registration = current_course.registrations.find params[:id]
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

  # NOTE: We allow the :id parameter in the has_many association's attributes
  #     hash since accepts_nested_attributes_for checks that each nested record
  #     actually belongs to the parent record.
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
