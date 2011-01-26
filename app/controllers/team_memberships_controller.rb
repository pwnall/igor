class TeamMembershipsController < ApplicationController
  before_filter :authenticated_as_admin
  
  # GET /team_memberships
  def index
    @team_memberships = TeamMembership.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /team_memberships/1
  def show
    @team_membership = TeamMembership.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /team_memberships/new
  def new
    @team_membership = TeamMembership.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /team_memberships
  def create
    @team_membership = TeamMembership.new(params[:team_membership])
    @user = User.find_first_by_query!(params[:query])
    @team_membership.user = @user

    respond_to do |format|
      if @team_membership.save
        format.html do
          redirect_to @team_membership.team.partition,
                      :notice => "#{@user.real_name} added to #{@team_membership.team.name}"
        end
      else
        format.html do
          flash[:error] = "#{@user.real_name} already belongs to a team in #{@team_membership.team.partition.name}"
          redirect_to @team_membership.team.partition
        end
      end
    end
  end

  # DELETE /team_memberships/1
  def destroy
    @team_membership = TeamMembership.find(params[:id])
    @team_membership.destroy

    respond_to do |format|
      format.html do
        redirect_to @team_membership.team.partition,
                    :notice => "#{@team_membership.user.real_name} removed from #{@team_membership.team.name}"
      end
    end
  end
end
