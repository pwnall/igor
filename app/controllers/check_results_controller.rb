class CheckResultsController < ApplicationController
  before_filter :authenticated_as_admin, :only => :index
  
  before_filter :authenticated_as_user, :only => :show

  
  # GET /check_results
  def index
    @check_results = CheckResult.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /check_results/1
  def show
    @check_result = CheckResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
