# == Schema Information
#
# Table name: grades
#
#  id           :integer          not null, primary key
#  course_id    :integer          not null
#  metric_id    :integer          not null
#  grader_id    :integer          not null
#  subject_type :string(64)
#  subject_id   :integer          not null
#  score        :decimal(8, 2)    not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# The grade awarded to a student/team for their performance on a metric.
class Grade < ActiveRecord::Base
  include AssignmentFeedback

  # The numeric grade.
  validates_numericality_of :score, only_integer: false

  # The users impacted by a grade.
  def users
    subject.respond_to?(:users) ? subject.users : [subject]
  end

  # Update/destroy this grade in response to a request from the grade editor.
  #
  # @param [String, Integer] score_text the numeric score
  # @return [Boolean] true if the grade was updated successfully
  def act_on_user_input(score_text)
    self.score = score_text
    if score_text.blank?
      destroy
      return true
    end
    save
  end
end
