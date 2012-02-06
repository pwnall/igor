class AnalyzersController < ApplicationController
  before_filter :authenticated_as_admin

  # XHR POST /analyzers/1/update_deliverable
  def update_deliverable
    # find the proper params hash
    params_hash = params[:script_analyzer] || params[:proc_analyzer] ||
                  params[:analyzer]

    # NOTE: not using reflection for security
    case params_hash[:type]
    when 'ScriptAnalyzer'
      new_class = ScriptAnalyzer
    when 'ProcAnalyzer'
      new_class = ProcAnalyzer
    else
      flash[:error] = "Invalid analyzer type."
      redirect_to root_path
      return
    end
    params_hash.delete :type
    
    # figure out whether we're creating or updating a record
    @deliverable = Deliverable.find params[:id]
    @deliverable.transaction do       
      if @deliverable.analyzer && @deliverable.analyzer.class != new_class
        @deliverable.analyzer.destroy
        @deliverable.analyzer = nil
      end
        
      @new_record = @deliverable.analyzer.nil?
      @deliverable.analyzer = new_class.new(params_hash) if @new_record
      @analyzer = @deliverable.analyzer

      # record / update data here
      @analyzer.time_limit ||= 60
      @success = @new_record ? @analyzer.save! : @analyzer.update_attributes!(params_hash)
      @deliverable.save! if @success
    end
    
    # render the result
    respond_to do |format|
      format.js  # update_deliverable.js.rjs
      if @success
        format.html do
          flash[:notice] = 
          redirect_to assignments_url,
                      notice: 'Analyzer was successfully updated.'
        end
      else
        format.html do
          redirect_to assignments_url, error: 'Failed to update analyzer.'
        end
      end
    end    
  end

  # GET /analyzers/1/contents
  def contents
    @anaylzer = Analyzer.find params[:id]
    db_file = @analyzer.db_file
    send_data full_db_file.f.file_contents,
              :filename => db_file.f.original_filename,
              :type => db_file.f.content_type
  end
end
