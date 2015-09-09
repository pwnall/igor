class RolesController < ApplicationController
  before_action :authenticated_as_user

  # DELETE /roles/1
  def destroy
    @role = Role.find params[:id]
    return bounce_user unless @role.can_destroy? current_user
    @role.destroy

    if @role.course
      redirect_to role_requests_url(course_id: @role.course),
          notice: "#{@role.user.name} is no longer a staff member."
    else
      redirect_to users_url,
          notice: "#{@role.user.name} is no longer an admin."
    end
  end
end
