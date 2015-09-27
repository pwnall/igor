class RoleRequestsController < ApplicationController
  before_action :set_current_course
  before_action :set_role_request, only: [:destroy, :approve, :deny]
  before_action :authenticated_as_user, except: [:index]
  before_action :authenticated_as_course_editor, only: [:index]

  # GET /6.006/role_requests
  def index
    @roles = current_course.roles.sort_by do |role|
      [role.name == 'grader' ? 1 : 0, role.user.name]
    end
    @role_requests = current_course.role_requests.sort_by do |request|
      [request.name == 'grader' ? 1 : 0, request.user.name]
    end
  end

  # GET /6.006/role_requests/1
  def show
    # NOTE: role requests get deleted after being approved / rejected, so their
    #       URLs would normally 404; this is an issue if users refresh the
    #       request page while waiting for an approval; we redirect them to the
    #       home page, and hope that the right thing happened
    @role_request = current_course.role_requests.find_by id: params[:id]
    unless @role_request
      redirect_to course_root_url(course_id: current_course)
      return
    end

    return bounce_user unless @role_request.user == current_user
  end

  # GET /6.006/role_requests/new
  def new
    # If a user already has a request (staff registration), show the request.
    role_request = current_user.role_requests.find_by course: current_course
    if role_request
      redirect_to role_request_url(role_request, course_id: current_course)
      return
    end

    @role_request = RoleRequest.new course: current_course
  end

  # POST /6.006/role_requests
  def create
    @role_request = RoleRequest.new role_request_params
    @role_request.course = current_course
    @role_request.user = current_user

    respond_to do |format|
      if @role_request.save
        RoleRequestMailer.notice_email(@role_request, root_url).deliver
        format.html do
          course = @role_request.course.number
          redirect_to role_request_url(@role_request,
                                       course_id: @role_request.course),
              notice: "#{course} staff access requested. Please wait for approval."
        end
      else
        format.html { render action: 'new' }
      end
    end
  end

  # DELETE /6.006/role_requests/1
  def destroy
    return bounce_user unless @role_request.can_destroy? current_user

    @role_request.destroy
    respond_to do |format|
      format.html do
        course = @role_request.course.number
        redirect_to connect_courses_url,
                    notice: "#{course} staff access request canceled."
      end
    end
  end

  # POST /6.006/role_requests/1/approve
  def approve
    bounce_user unless @role_request.can_edit? current_user

    @role_request.approve
    @role_request.destroy
    RoleRequestMailer.decision_email(@role_request, true, root_url).deliver

    name = @role_request.user.name
    course = @role_request.course.number
    redirect_to role_requests_url(course_id: @role_request.course),
        notice: "#{name} is now a #{course} staff member"
  end

  # POST /role_requests/1/deny
  def deny
    bounce_user unless @role_request.can_edit? current_user

    @role_request.destroy
    RoleRequestMailer.decision_email(@role_request, false, root_url).deliver

    name = @role_request.user.name
    course = @role_request.course.number
    redirect_to role_requests_url(course_id: @role_request.course),
        notice: "#{name} was denied #{course} staff access"
  end

  def set_role_request
    @role_request = RoleRequest.find(params[:id])
  end
  private :set_role_request

  def role_request_params
    params.require(:role_request).permit :name
  end
  private :role_request_params
end
