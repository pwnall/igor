class RecitationSectionsController < ApplicationController
  before_filter :authenticated_as_admin

  # GET /recitation_sections
  def index
    @recitation_sections = RecitationSection.find(:all, :include => :leader)
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /recitation_sections/1
  def show
    @recitation_section = RecitationSection.find(params[:id])
    new_edit
    #
    #respond_to do |format|
    #  format.html # show.html.erb
    #end
  end

  # GET /recitation_sections/new
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
    respond_to do |format|
      format.html { render :action => :new_edit }
    end
  end
  private :new_edit
  

  # POST /recitation_sections
  def create
    @recitation_section = RecitationSection.new(params[:recitation_section])
    create_update
  end

  # PUT /recitation_sections/1
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
        notice_message = "Recitation section R#{'%02d' % @recitation_section.serial} successfully #{@is_new_record ? 'created' : 'updated'}."
        format.html { redirect_to(@recitation_section, :action => :index, :notice => notice_message) }
        format.json { head :ok }
      else
        format.html { render :action => :new_edit } 
        format.json { render :json => @recitation_section.errors.full_messages, :status => :unprocessable_entity }
      end
    end    
  end
  private :create_update

  # DELETE /recitation_sections/1
  def destroy
    @recitation_section = RecitationSection.find(params[:id])
    @recitation_section.destroy

    respond_to do |format|
      format.html { redirect_to(recitation_sections_url) }
    end
  end
end
