class RolesController < ApplicationController
  before_filter :authenticated_as_admin

  # DELETE /roles/1
  def destroy
    @role = Role.find params[:id]
    @role.destroy

    redirect_to role_requests_url,
        notice: "#{@role.user.name} is no longer a staff member."
  end
end
