# Grade and GradeComment management through the grade editor UI.
module GradeEditor
  # Build a Grade or GradeComment to be displayed in the grade editor.
  #
  # @param [Class] klass the class of the feedback object: Grade or GradeComment
  # @param [ActionController::Parameters] params the feedback parameters hash
  #     containing :subject_type, :subject_id, and :metric_id
  # @return [Grade, GradeComment] the grade or comment that corresponds to the
  #     attributes in the given parameters
  def find_or_build_feedback(klass, params)
    @subject = AssignmentFeedback.find_subject params[:subject_type],
                                               params[:subject_id]
    @metric = current_course.assignment_metrics.find params[:metric_id]
    unless feedback = klass.where(subject: @subject, metric: @metric).first
      feedback = klass.new subject: @subject, metric: @metric
    end
    # TODO: check that the subject is reasonable and belongs to the course
    feedback.grader = current_user
    feedback
  end
end
