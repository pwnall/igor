module SubmissionsHelper
  include UsersHelper  # For user_image_tag.
  include IconsHelper  # For analysis_status_icon_tag.

  # The submission's promoted state in text, or a button to promote it.
  def submission_promotion_status(submission, user)
    if submission == submission.deliverable.submission_for_grading(user)
      content_tag :div, class: 'promoted-status no-text' do
        promote_icon_tag title: 'Selected for grading'
      end
    else
      button_to promote_submission_path(submission,
          course_id: submission.course), class: "no-text" do
        promote_icon_tag
      end
    end
  end

  # The object of a new collaboration form for the given submission.
  #
  # @param [Collaboration] invalid_collaboration a collaboration from the
  #     previous request, if it failed validations; otherwise, nil
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

  # A <figure> tag displaying the given submission's author and status.
  def submission_figure(submission)
    content_tag :figure, title: submission.subject.name,
        class: 'submission-figure' do
      user_image_tag(submission.subject, size: :medium) +
      analysis_status_badge_tag(submission.analysis)
    end
  end
end
