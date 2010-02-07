class ProfilesController < ApplicationController
  include ApplicationHelper

  before_filter :authenticated_as_user, :only => [:new, :create, :edit, :update, :websis_lookup]
  before_filter :authenticated_as_admin, :only => [:index, :show, :destroy]

  # GET /profiles
  # GET /profiles.xml
  def index
    @profiles = Profile.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end
  
  # XHR /profiles/websis_lookup/0?athena_id=costan
  def websis_lookup
    @athena_username = params[:athena_id]
    @athena_info = MitStalker.from_user_name @athena_username
    @year_options = profile_year_options @athena_info[:year] unless @athena_info.nil?
    respond_to do |format|
      format.js # websis_lookup.js.rjs
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @profile = Profile.find(params[:id])

    @year_options = profile_year_options @profile.year
    @recitation_section_options = profile_recitation_section_options @profile.recitation_section_id

    respond_to do |format|
      format.html
      format.xml  { render :xml => @profile }
    end
  end

  def new_edit(manual)
    @manual = manual
    
    if @profile.new_record?
      unless manual
        @profile.athena_username = @s_user.email.split('@')[0]
      end
    else
      if !@s_user.admin && @s_user.id != @profile.user_id
        # Don't let normal users edit other users' profiles.
        notice[:error] = 'That is not yours to play with! Your attempt has been logged.'
        redirect_to root_url
        return
      end
    end
    
    @year_options = profile_year_options @profile.year
    @recitation_section_options = profile_recitation_section_options @profile.recitation_section_id

    respond_to do |format|
      format.html { render :action => :new_edit }
      format.xml  { render :xml => @profile }
    end    
  end
  private :new_edit
  
  # GET /profiles/my_own
  def my_own
    @profile = @s_user.profile || Profile.new(:user => @s_user)
    new_edit false
  end
  
  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    @profile = Profile.new
    new_edit false
  end

  # GET /profiles/1/edit
  def edit
    @profile = Profile.find(params[:id])
    new_edit false
  end
  
  def new_manual
    @profile = Profile.new
    new_edit true
  end
    
  def create_update(manual)
    @manual = manual
    
    is_new_record = @profile.new_record?
    if is_new_record
      @profile.user = manual ? @new_user : @s_user       
    else
      if !@s_user.admin && @s_user.id != @profile.user_id
        # do not allow random record updates
        notice[:error] = 'That is not yours to play with! Your attempt has been logged.'
        redirect_to root_path
        return
      end
    end

        
    if is_new_record
      success = @profile.save
    else
      success = @profile.update_attributes(params[:profile])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Profile successfully #{is_new_record ? 'created' : 'updated'}."
        format.html { redirect_to root_path }
        format.xml do
          if is_new_record
            render :xml => @profile, :status => :created, :location => @profile
          else
            head :ok
          end  
        end  
      else
        @year_options = profile_year_options @profile
        @recitation_section_options = profile_recitation_section_options @profile.recitation_section_id        
        format.html { render :action => :new_edit }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end    
  end
  private :create_update

  # POST /profiles
  # POST /profiles.xml
  def create
    @profile = Profile.new(params[:profile])
    create_update(false)    
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @profile = Profile.find(params[:id])
    create_update(false)
  end
  
  def create_manual
    @new_user = User.new(:name => "dummy_#{Time.now.to_i}", :password => 'superdummy', :email => 'costan@mit.edu', :active => false, :admin => false)
    @new_user.save!

    @profile = Profile.new(params[:profile])
    create_update(true)
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(profiles_url) }
      format.xml  { head :ok }
    end
  end
  

  private
  # make the right year stick in FF/tarded by putting it as the first option   
  def profile_year_options(profile_year)
    options = [['Freshman (1)', '1'], ['Sophomore (2)', '2'], ['Junior (3)', '3'], ['Senior (4)', '4'], ['Graduate (G)', 'G']]
    yr_index = (0...(options.length)).find { |i| options[i][1] == profile_year }
    options = options[yr_index...(options.length)] + options[0...yr_index] unless yr_index.nil?
    return options
  end  
  
  def profile_recitation_section_options(profile_recitation_section_id)
    options = [['(none)', nil]] + RecitationSection.find(:all).map { |s| [display_name_for_recitation_section(s), s.id] }
    rs_index = (0...(options.length)).find { |i| options[i][1] == profile_recitation_section_id }
    options = options[rs_index...(options.length)] + options[0...rs_index] unless rs_index.nil?
    return options
  end
end
