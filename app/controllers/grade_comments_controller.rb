class GradeCommentsController < ApplicationController
  include GradeEditor

  before_action :set_current_course
  before_action :authenticated_as_course_editor

  # XHR POST /6.006/grade_comments
  def create
    success = GradeComment.transaction do
      @comment = find_or_build_feedback GradeComment, grade_comment_params
      @comment.act_on_user_input grade_comment_params[:text]
    end
    if success
      @metric = @comment.metric
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
