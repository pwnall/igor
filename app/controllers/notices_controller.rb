class NoticesController < ApplicationController
  before_filter :authenticated_as_admin, :except => [:dismiss]
  
  # XHR /dismiss/1
  def dismiss
    @notice_status = NoticeStatus.find(params[:id])

    if @notice_status.user_id != @s_user.id
      # the notice isn't yours to remove, bitch
    else
      @notice = @notice_status.notice
      @notice_status.destroy
      @notice.dismissed_count += 1
      @notice.save!
      respond_to do |format|
        format.js
      end
    end
  end
  
  # GET /notices
  # GET /notices.xml
  def index
    @notices = Notice.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notices }
    end
  end

  # GET /notices/1
  # GET /notices/1.xml
  def show
    @notice = Notice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notice }
    end
  end

  # GET /notices/new
  # GET /notices/new.xml
  def new
    @notice = Notice.new
    new_edit
  end

  # GET /notices/1/edit
  def edit
    @notice = Notice.find(params[:id])
    new_edit
  end
  
  def new_edit
    respond_to do |format|
      format.html { render :action => :new_edit }
      format.xml  { render :xml => @notice }
    end
  end  

  # POST /notices
  # POST /notices.xml
  def create
    @notice = Notice.new(params[:notice])
    create_update
  end

  # PUT /notices/1
  # PUT /notices/1.xml
  def update
    @notice = Notice.find(params[:id])
    create_update
  end

  def create_update
    @is_new_record = @notice.new_record?
    if @is_new_record
      success = @notice.save
    else
      success = @notice.update_attributes(params[:notice])
    end
    
    respond_to do |format|
      if success
        flash[:notice] = "Site-wide notice successfully #{@is_new_record ? 'submitted' : 'updated'}."
        @notice.post_to_all_users if @is_new_record
        format.html { redirect_to(:controller => :notices, :action => :index) }
        format.xml do
          if is_new_record
            render :xml => @assignment_metric, :status => :created, :location => @notice
          else
            head :ok
          end  
        end  
      else
        format.html { render :action => :new_edit }
        format.xml  { render :xml => @notice.errors, :status => :unprocessable_entity }
      end
    end    
  end

  # DELETE /notices/1
  # DELETE /notices/1.xml
  def destroy
    @notice = Notice.find(params[:id])
    @notice.destroy

    respond_to do |format|
      format.html { redirect_to(notices_url) }
      format.xml  { head :ok }
    end
  end
end
