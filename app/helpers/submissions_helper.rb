module SubmissionsHelper
  # The submission's promoted state in text, or a button to promote it.
  def submission_promotion_status(submission, user)
    if submission == submission.deliverable.submission_for_grading(user)
      content_tag :span, 'Selected for grading'
    else
      link_to 'Select for grading',
          promote_submission_path(submission, course_id: submission.course),
          class: "button", method: :post
    end
  end

  # The object of a new collaboration form for the given submission.
  #
  # @param [Collaboration] invalid_collaboration a collaboration from the
  #     previous request, if it failed validations
  # @param [Submission] submission the object of the collaboration
  # @return [Submission] the previous invalid submission, or a new submission
  def new_collaboration(invalid_collaboration, submission)
    if invalid_collaboration &&
        (invalid_collaboration.submission == submission)
      invalid_collaboration
    else
      Collaboration.new
    end
  end

  # Text that identifies the collaborator in the collaboration.
  def collaborator_display_name(collaborator)
    "#{collaborator.email} (#{collaborator.profile.name})"
  end
end
