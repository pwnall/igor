class ProfilesController < ApplicationController
  before_action :authenticated_as_user, only: [:show]

  # GET /profiles/1
  def show
    @profile = Profile.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  # create, edit, update, and destroy are all implemented in UserController.

  # Listing all profiles can be done via UsersController (for site admins),
  # or via RegistrationsController (for course staff).

  # XHR POST /profiles/websis_lookup
  def websis_lookup
    @athena_username = if params[:user]
      params[:user][:profile_attributes][:athena_username]
    elsif params[:profile]
      params[:profile][:athena_username]
    else
      params[:athena_username]
    end

    if @athena_username.blank?
      @athena_info = nil
    else
      @athena_info = MitStalker.from_user_name @athena_username
    end
    respond_to do |format|
      format.html { render layout: false }  # websis_lookup.html.erb
    end
  end
end
