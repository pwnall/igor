class ExamSessionsController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_user
  before_action :set_exam_session

  # POST /6.006/exam_sessions/1/check_in
  def check_in
    return bounce_user unless @exam_session.can_check_in? current_user
    @attendance = @exam_session.build_attendance_for_user current_user

    respond_to do |format|
      if @attendance.save
        format.html do
          redirect_to exam_session_panel_url(@exam_session),
              notice: "You have checked-in to exam session #{@exam_session.name}."
        end
      else
        format.html do
          redirect_to exam_session_panel_url(@exam_session),
              notice: "You could not be checked in."
        end
      end
    end
  end

  def set_exam_session
    @exam_session = current_course.exam_sessions.find params[:id]
  end
  private :set_exam_session
end
