class ApiController < ApplicationController
  def conflict_info
    @student_infos = StudentInfo.find :all, :include => :recitation_conflicts
    
    @response_data = @student_infos.map do |s|
      conflicts = s.recitation_conflicts.map do |r|
        { :timeslot => r.timeslot, :class => r.class_name }
      end
      
      {
        :athena => s.user.athena_id,
        :credit => s.wants_credit,
        :conflicts => conflicts
      }
    end
    @response = { :info => @response_data }
       
    respond_to do |format|
      format.json { render :json => @response, :callback => params[:callback] }
    end
  end
end
