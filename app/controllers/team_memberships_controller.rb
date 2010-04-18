class TeamMembershipsController < ApplicationController
  before_filter :authenticated_as_admin
  
  # GET /team_memberships
  # GET /team_memberships.xml
  def index
    @team_memberships = TeamMembership.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @team_memberships }
    end
  end

  # GET /team_memberships/1
  # GET /team_memberships/1.xml
  def show
    @team_membership = TeamMembership.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team_membership }
    end
  end

  # GET /team_memberships/new
  # GET /team_memberships/new.xml
  def new
    @team_membership = TeamMembership.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team_membership }
    end
  end

  # POST /team_memberships
  # POST /team_memberships.xml
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
        format.xml  { render :xml => @team_membership, :status => :created, :location => @team_membership }
      else
        format.html do
          flash[:error] = "#{@user.real_name} already belongs to a team in #{@team_membership.team.partition.name}"
          redirect_to @team_membership.team.partition
        end
        format.xml  { render :xml => @team_membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /team_memberships/1
  # DELETE /team_memberships/1.xml
  def destroy
    @team_membership = TeamMembership.find(params[:id])
    @team_membership.destroy

    respond_to do |format|
      format.html do
        redirect_to @team_membership.team.partition,
                    :notice => "#{@team_membership.user.real_name} removed from #{@team_membership.team.name}"
      end
      format.xml  { head :ok }
    end
  end
end
