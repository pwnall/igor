class ApiController < ApplicationController
  def conflict_info
    @registrations = Registration.joins(:user).find(:all, 
                                                    :include => :recitation_conflicts,
                                                    :conditions => { :users => { :admin => false }})
    
    @response_data = @registrations.map do |s|
      conflicts = s.recitation_conflicts.map do |r|
        { :timeslot => r.timeslot, :class => r.class_name }
      end
      
      {
        :athena => s.user.athena_id,
        :credit => s.for_credit,
        :conflicts => conflicts
      }
    end
    @response = { :info => @response_data }
       
    respond_to do |format|
      format.json { render :json => @response, :callback => params[:callback] }
    end
  end
end
