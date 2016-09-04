class ApiController < ApplicationController
  skip_before_action :authenticate_using_session
  authenticates_using_http_token
  before_action :authenticated_as_user

  # GET /_/api/0/user_info
  def user_info
    @user = current_user
  end

  # GET /_/api/0/assignments?course=1.337
  def assignments
    course = Course.where(number: params[:course]).first
    @assignments = course.assignments.includes(:deliverables).
        select { |assignment| assignment.can_read_content? current_user }
  end

  # GET /_/api/0/submissions?course=1.337
  def submissions
    course = Course.where(number: params[:course]).first
    deliverables = course.deliverables
    @submissions = current_user.submissions.where(deliverable: deliverables).
                                all
  end
end
