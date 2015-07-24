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
end
