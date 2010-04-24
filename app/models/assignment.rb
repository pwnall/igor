# == Schema Information
# Schema version: 20100216020942
#
# Table name: assignments
#
#  id                       :integer(4)      not null, primary key
#  deadline                 :datetime        not null
#  name                     :string(64)      not null
#  team_partition_id        :integer(4)
#  feedback_question_set_id :integer(4)
#  accepts_feedback         :boolean(1)      not null
#  created_at               :datetime
#  updated_at               :datetime
#

# An assignment for the course students. (e.g., a problem set or a project)
class Assignment < ActiveRecord::Base
  # The deliverables that students need to submit to complete the assignment.
  has_many :deliverables, :dependent => :destroy
  # The metrics that the students are graded on for this assignment.
  has_many :metrics, :class_name => 'AssignmentMetric', :dependent => :destroy
  
  # The user-visible assignment name (e.g., "PSet 1").
  validates_length_of :name, :in => 1..64, :allow_nil => false
  validates_uniqueness_of :name
  
  # The time when all the deliverables of the assignment are due.
  validates_presence_of :deadline

  # The partition of teams used for this assignment.
  belongs_to :team_partition
  
  # The set of feedback questions for this assignment. 
  belongs_to :feedback_question_set
  
  # The feedback questions for this assignment. 
  def feedback_questions
    # NOTE: this should be a has_many :through association, except ActiveRecord
    #       doesn't support nested :through associations 
    feedback_question_set.questions
  end
end
