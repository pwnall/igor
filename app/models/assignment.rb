# == Schema Information
# Schema version: 20110208012638
#
# Table name: assignments
#
#  id                 :integer(4)      not null, primary key
#  deadline           :datetime        not null
#  name               :string(64)      not null
#  team_partition_id  :integer(4)
#  feedback_survey_id :integer(4)
#  accepts_feedback   :boolean(1)      not null
#  created_at         :datetime
#  updated_at         :datetime
#

# An assignment for the course students. (e.g., a problem set or a project)
class Assignment < ActiveRecord::Base
  # The deliverables that students need to submit to complete the assignment.
  has_many :deliverables, :dependent => :destroy
  # The metrics that the students are graded on for this assignment.
  has_many :metrics, :class_name => 'AssignmentMetric', :dependent => :destroy
  
  # The user-visible assignment name (e.g., "PSet 1").
  validates :name, :length => 1..64, :uniqueness => true, :presence => true
  
  # The time when all the deliverables of the assignment are due.
  validates :deadline, :presence => true

  # The partition of teams used for this assignment.
  belongs_to :team_partition
  
  # The set of survey questions for getting feedback on this assignment. 
  belongs_to :feedback_survey, :class_name => 'Survey'
  
  # The questions in the feedback survey for this assignment. 
  def feedback_questions
    # NOTE: this should be a has_many :through association, except ActiveRecord
    #       doesn't support nested :through associations 
    feedback_survey.questions
  end
  
  # The assignment deadline, customized to a specific user.
  #
  # This method will eventually account for deadline extensions. 
  def deadline_for_user(user)
    deadline
  end
  
  # True if the sumbissions for this assignment should be marked as late.
  #
  # This method takes an user as an argument so that we can later account for
  # deadline extensions.
  def deadline_passed_for_user?(user)
    deadline < Time.now
  end
end
