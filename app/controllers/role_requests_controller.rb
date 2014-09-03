class RoleRequestsController < ApplicationController
  before_action :set_role_request, only: [:destroy, :approve, :deny]
  before_filter :authenticated_as_user, only: [:show, :new, :create, :destroy]
  before_filter :authenticated_as_admin, except: [:show, :new, :create,
                                                  :destroy]

  # GET /role_requests
  def index
    course = Course.main
    @roles = course.roles.sort_by do |role|
      [role.name == 'grader' ? 1 : 0, role.user.name]
    end
    @role_requests = course.role_requests.sort_by do |request|
      [request.name == 'grader' ? 1 : 0, request.user.name]
    end
  end

  # GET /role_requests/1
  def show
    # NOTE: role requests get deleted after being approved / rejected, so their
    #       URLs would normally 404; this is an issue if users refresh the
    #       request page while waiting for an approval; we redirect them to the
    #       home page, and hope that the right thing happened
    @role_request = RoleRequest.where(params[:id]).first
    unless @role_request
      redirect_to session_url
      return
    end

    return bounce_user unless @role_request.user == current_user
  end

  # GET /role_requests/new
  def new
    # If a user already has a request (staff registration), show the request.
    unless current_user.role_requests.empty?
      redirect_to current_user.role_requests.first
      return
    end

    course = Course.main
    @role_request = RoleRequest.new course: course
  end

  # POST /role_requests
  def create
    @role_request = RoleRequest.new role_request_params
    @role_request.user = current_user

    respond_to do |format|
      if @role_request.save
        if @role_request.course.email_on_role_requests
          RoleRequestMailer.notice_email(@role_request, root_url).deliver
        end
        format.html do
          redirect_to @role_request,
              notice: 'Staff registration request created. Please wait for approval.'
        end
      else
        format.html { render action: 'new' }
      end
    end
  end

  # DELETE /role_requests/1
  def destroy
    return bounce_user unless @role_request.user == current_user

    @role_request.destroy
    respond_to do |format|
      format.html do
        redirect_to new_registration_url,
                    notice: 'Staff registration canceled.'
      end
    end
  end

  # POST /role_requests/1/approve
  def approve
    @role_request.approve
    @role_request.destroy
    RoleRequestMailer.decision_email(@role_request, true, root_url).deliver

    redirect_to role_requests_url,
        notice: "#{@role_request.user.name} is now a staff member"
  end

  # POST /role_requests/1/deny
  def deny
    @role_request.destroy
    RoleRequestMailer.decision_email(@role_request, false, root_url).deliver
    redirect_to role_requests_url,
        notice: "#{@role_request.user.name} was denied staff registration"
  end

  def set_role_request
    @role_request = RoleRequest.find(params[:id])
  end
  private :set_role_request

  def role_request_params
    params.require(:role_request).permit :name, :course_id
  end
  private :role_request_params
end
