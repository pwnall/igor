class JobsController < ApplicationController
  before_action :authenticated_as_admin

  # GET /_/jobs
  def index
    @jobs = Delayed::Job.order(created_at: :desc).all
  end

  # GET /_/jobs/1
  def show
    @job = Delayed::Job.find params[:id]
  end
end
