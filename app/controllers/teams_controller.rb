class TeamsController < ApplicationController
  before_filter :authenticated_as_admin, :except => [:my_own]
  before_filter :authenticated_as_user, :only => [:my_own]

  # GET /teams/my_own
  def my_own
    @teams = @s_user.teams(:include => { :users => :profiles,
                                         :team_partition => :assignments }).
                     select { |t| t.partition.published? }.reverse
    respond_to do |format|
      format.html # my_own.html.erb
      format.xml  { render :xml => @teams }
    end
  end

  # GET /teams
  # GET /teams.xml
  def index
    @teams = Team.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teams }
    end
  end

  # GET /teams/1
  # GET /teams/1.xml
  def show
    @team = Team.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /teams/new
  # GET /teams/new.xml
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  # POST /teams.xml
  def create
    @team = Team.new(params[:team])

    respond_to do |format|
      if @team.save
        format.html { redirect_to(@team, :notice => 'Team was successfully created.') }
        format.xml  { render :xml => @team, :status => :created, :location => @team }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.xml
  def update
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        format.html { redirect_to(@team, :notice => 'Team was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.xml
  def destroy
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to(teams_url) }
      format.xml  { head :ok }
    end
  end
  
  # POST /teams/1/remove_user?user_id=5
  # POST /teams/1/remove_user.xml?user_id=5
  def remove_user
    @team = Team.find(params[:id])
    @user = User.find(params[:user_id])
    
    membership = @team.memberships.first :conditions => { :user_id => @user.id }
    membership.destroy
    
    respond_to do |format|
      format.html do
        redirect_to @team.partition,
                    :notice => "#{@user.real_name} removed from #{@team.name}"
      end
      format.xml  { head :ok }
    end
  end
end
