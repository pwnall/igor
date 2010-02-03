class RecitationSectionsController < ApplicationController
  before_filter :authenticated_as_admin

  [:leader_id, :time, :location, :serial].each { |field| in_place_edit_for :recitation_section, field }

  # GET /recitation_sections
  # GET /recitation_sections.xml
  def index
    @recitation_sections = RecitationSection.find(:all, :include => :leader)
    @leaders = User.find(:all, :conditions => {:admin => true}, :include => :profile)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recitation_sections }
    end
  end

  # GET /recitation_sections/1
  # GET /recitation_sections/1.xml
  def show
    @recitation_section = RecitationSection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @recitation_section }
    end
  end

  # GET /recitation_sections/new
  # GET /recitation_sections/new.xml
  def new
    @recitation_section = RecitationSection.new
    @recitation_section.serial = 1 + RecitationSection.count
    new_edit
  end

  # GET /recitation_sections/1/edit
  def edit
    @recitation_section = RecitationSection.find(params[:id])
    new_edit
  end
  
  def new_edit
    @leaders = User.find(:all, :conditions => {:admin => true}, :include => :profile)
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.xml  { render :xml => @recitation_section }
    end
  end
  private :new_edit
  

  # POST /recitation_sections
  # POST /recitation_sections.xml
  def create
    @recitation_section = RecitationSection.new(params[:recitation_section])
    create_update
  end

  # PUT /recitation_sections/1
  # PUT /recitation_sections/1.xml
  def update
    @recitation_section = RecitationSection.find(params[:id])
    create_update
  end
  
  def create_update
    @is_new_record = @recitation_section.new_record?
    if @is_new_record
      success = @recitation_section.save
    else
      success = @recitation_section.update_attributes(params[:recitation_section])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Recitation section R#{'%02d' % @recitation_section.serial} successfully #{@is_new_record ? 'created' : 'updated'}."
        format.html { redirect_to(:controller => :recitation_sections, :action => :index) }
        format.xml do
          if is_new_record
            render :xml => @recitation_section, :status => :created, :location => @recitation_section
          else
            head :ok
          end  
        end  
      else
        format.html { render :action => :new_edit }
        format.xml  { render :xml => @recitation_section.errors, :status => :unprocessable_entity }
      end
    end    
  end
  private :create_update

  # DELETE /recitation_sections/1
  # DELETE /recitation_sections/1.xml
  def destroy
    @recitation_section = RecitationSection.find(params[:id])
    @recitation_section.destroy

    respond_to do |format|
      format.html { redirect_to(recitation_sections_url) }
      format.xml  { head :ok }
    end
  end
end
