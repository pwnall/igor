class RegistrationsController < ApplicationController
  before_filter :authenticated_as_user, only: [:show, :new, :create, :edit,
                                               :update]
  before_filter :authenticated_as_admin,
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
    @registration = Registration.find params[:id]
    return bounce_user unless @registration.can_edit?(current_user)

    if @registration.can_edit?(current_user) and
        @registration.course.has_recitations?
      @recitation_conflicts = @registration.recitation_conflicts.
                                            index_by(&:timeslot)
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
    @registration = Registration.new user: current_user, course: course
    @registration.build_prerequisite_answers
    @recitation_conflicts = {}
  end

  # GET /registrations/1/edit
  def edit
    @registration = Registration.find params[:id]
    @recitation_conflicts = @registration.recitation_conflicts.
                                          index_by(&:timeslot)
    # Disallow random record updates.
    unless @registration.can_edit? current_user
      notice[:error] = 'That is not yours to play with! Attempt logged.'
      redirect_to root_path
      return
    end
  end

  # POST /registrations
  def create
    @registration = Registration.new registration_params
    @registration.user = current_user
    @registration.course = Course.main

    if @registration.course.has_recitations?
      if params[:recitation_conflicts]
        @registration.update_conflicts params[:recitation_conflicts]
        @recitation_conflicts = @registration.recitation_conflicts.
                                              index_by(&:timeslot)
      else
        @recitation_conflicts = {}
      end
    end

    respond_to do |format|
      if @registration.save
        format.html do
          redirect_to root_url, notice:
              "You are now registered for #{@registration.course.number}."
        end
      else
        format.html { render action: :new }
      end
    end
  end

  # PUT /registrations/1
  def update
    @registration = Registration.find params[:id]

    unless @registration.can_edit? current_user
      # Disallow random record updates.
      notice[:error] = 'That is not yours to play with! Your attempt has been logged.'
      redirect_to root_path
      return
    end

    if params[:recitation_conflicts]
      @registration.update_conflicts params[:recitation_conflicts]
    end

    respond_to do |format|
      if @registration.update_attributes registration_params
        format.html do
          redirect_to root_url, notice:
              "#{@registration.course.number} registration info updated."
        end
      else
        format.html { render action: :edit }
      end
    end
  end

  def registration_params
    params.require(:registration).permit :for_credit, :allows_publishing,
        prerequisite_answers_attributes: [:took_course, :prerequisite_id,
                                          :waiver_answer]
  end
  private :registration_params
end
