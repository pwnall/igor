class AnalysesController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_admin, :only => :index
  before_action :authenticated_as_user, :only => :show

  # GET /analyses/1
  def show
    @analysis = Analysis.find params[:id]
    return bounce_user unless @analysis.can_read? current_user

    respond_to do |format|
      format.html  # show.html.erb
    end
  end
end
