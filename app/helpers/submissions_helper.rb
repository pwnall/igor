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

  # An icon that links to the given submission's analysis, if one exists.
  def submission_figure(submission)
    analysis = submission.analysis
    if analysis
      link_to analysis_path(analysis, course_id: submission.course) do
        render 'deliverables/submission_figure', submission: submission
      end
    else
      render 'deliverables/submission_figure', submission: submission
    end
  end
end
