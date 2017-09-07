# == Schema Information
#
# Table name: grade_comments
#
#  id           :integer          not null, primary key
#  course_id    :integer          not null
#  metric_id    :integer          not null
#  grader_id    :integer          not null
#  subject_type :string(16)       not null
#  subject_id   :integer          not null
#  text         :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# A comment for a grade.
#
# Graders can leave comments to explain their grading. Comments are expected to
# be rare, so they're stored in a separate table to avoid swelling up grade
# records and slowing down stat computations that have to instantiate a lot of
# Grade models.
class GradeComment < ApplicationRecord
  include AssignmentFeedback

  # The comment text.
  # TODO(pwnall): consider allowing safe markdown here.
  validates :text, presence: true, length: 1..4.kilobytes

  # Update/destroy this comment in response to a request from the grade editor.
  #
  # @param [String] comment_text the comment text; if empty or null, the comment
  #     will be destroyed
  # @return [Boolean] true if the comment was updated successfully
  def act_on_user_input(comment_text)
    self.text = comment_text
    if comment_text.blank?
      destroy
      return true
    end
    save
  end
end
