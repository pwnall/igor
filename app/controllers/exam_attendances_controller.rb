class ExamAttendancesController < ApplicationController
  before_action :set_current_course
  before_action :authenticated_as_course_editor, except: [:create]
  before_action :authenticated_as_user, only: [:create]
  before_action :set_exam, only: [:index]
  before_action :set_exam_session, only: [:create]
  before_action :set_attendance, only: [:update]

  # GET /6.006/exams/1/attendances
  def index
    if params[:exam_session_id].blank?
      @attendances = @exam.attendances.by_student_name
    else
      @exam_session = @exam.exam_sessions.find params[:exam_session_id]
      @attendances = @exam_session.attendances.by_student_name
    end

    respond_to do |format|
      format.html
    end
  end

  # POST /6.006/exam_sessions/1/attendances
  def create
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

  # XHR PATCH /6.006/attendances/1
  def update
    if @attendance.update attendance_params
      render 'exam_attendances/edit', layout: false
    else
      head :not_acceptable
    end
  end

  def set_exam
    @exam = Exam.find params[:exam_id]
    return bounce_user unless @exam.course == current_course
  end
  private :set_exam

  def set_exam_session
    @exam_session = current_course.exam_sessions.find params[:exam_session_id]
  end
  private :set_exam_session

  def set_attendance
    @attendance = ExamAttendance.find params[:id]
    return bounce_user unless @attendance.course == current_course
  end
  private :set_attendance

  def attendance_params
    params.require(:attendance).permit :confirmed
  end
  private :attendance_params
end
