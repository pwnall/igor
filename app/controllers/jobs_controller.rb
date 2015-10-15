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

  # DELETE /_/jobs/failed
  def destroy_failed
    @jobs = Delayed::Job.all.select { |j| j.failed_at }
    @jobs.each(&:destroy)

    redirect_to jobs_url, notice: "#{@jobs.length} failed jobs removed"
  end
end
