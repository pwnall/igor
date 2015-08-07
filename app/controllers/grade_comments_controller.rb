class GradeCommentsController < ApplicationController
  include GradeEditor

  before_action :set_current_course
  before_action :authenticated_as_course_editor

  # XHR POST /6.006/grade_comments
  def create
    comment = find_or_build_feedback GradeComment, grade_comment_params
    if comment.act_on_user_input grade_comment_params[:text]
      render 'grades/edit', layout: false
    else
      head :not_acceptable
    end
  end

  def grade_comment_params
    params.require(:comment).permit :subject_id, :subject_type, :metric_id,
                                    :text
  end
  private :grade_comment_params
end
