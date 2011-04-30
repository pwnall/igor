class SubmissionCheckersController < ApplicationController
  before_filter :authenticated_as_admin

  # XHR POST /submission_checkers/1/update_deliverable
  def update_deliverable
    # find the proper params hash
    params_hash = params[:script_checker] || params[:proc_checker] ||
                  params[:submission_checker]

    # NOTE: not using reflection for security
    case params_hash[:type]
    when 'ScriptChecker'
      new_class = ScriptChecker
    when 'ProcChecker'
      new_class = ProcChecker
    else
      flash[:error] = "Invalid checker type."
      redirect_to root_path
      return
    end
    params_hash.delete :type
    
    # figure out whether we're creating or updating a record
    @deliverable = Deliverable.find(params[:id])
    @deliverable.transaction do       
      if @deliverable.submission_checker && @deliverable.submission_checker.class != new_class
        @deliverable.submission_checker.destroy
        @deliverable.submission_checker = nil
      end
        
      @new_record = @deliverable.submission_checker.nil?
      @deliverable.submission_checker = new_class.new(params_hash) if @new_record
      @checker = @deliverable.submission_checker

      # record / update data here
      @checker.time_limit ||= 60
      @success = @new_record ? @checker.save! : @checker.update_attributes!(params_hash)
      @deliverable.save! if @success
    end
    
    # render the result
    respond_to do |format|
      format.js  # update_deliverable.js.rjs
      if @success
        format.html do
          flash[:notice] = 'Submission checker was successfully updated.'
          redirect_to :controller => :assignments, :action => :index
        end
      else
        format.html do
          flash[:error] = 'Failed to update submission checker.'
          redirect_to :controller => :assignments, :action => :index
        end
      end
    end    
  end

  # GET /submission_checkers/1/contents
  def contents
    @checker = SubmissionChecker.find params[:id]
    db_file = @checker.db_file
    send_data full_db_file.f.file_contents,
              :filename => db_file.f.original_filename,
              :type => db_file.f.content_type
  end
end
