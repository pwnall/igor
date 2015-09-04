# Build objects that read in datetime attributes via the datetime_select helper.
module DateSelectParamParser
  # Build an extension for the given subject.
  #
  # @param [Assignment, Survey] subject the subject of the extension
  # @param [ActionController::Parameters] params the extension parameters hash
  #     containing :user_id (User :exuid), and the parameters that comprise the
  #     the due date: :due_at(1i), :due_at(2i), ..., :due_at(5i)
  # @return [DeadlineExtension] an extension for this assignment with the given
  #     parameters
  def build_extension(subject, params)
    user = subject.course.users.with_param(params[:user_id]).first
    due_at = DeadlineExtension.new(params).due_at
    subject.extensions.build user: user, due_at: due_at
  end
end
