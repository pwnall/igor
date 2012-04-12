class AnalysesController < ApplicationController
  before_filter :authenticated_as_admin, :only => :index
  
  before_filter :authenticated_as_user, :only => :show
  
  # GET /analyses/1
  def show
    @analysis = Analysis.find params[:id]
    return bounce_user unless @analysis.can_read? current_user

    respond_to do |format|
      format.html  # show.html.erb
    end
  end
end
