# A piece of work that students have to complete.
#
# Examples: problem set, project, exam.
class Assignment < ActiveRecord::Base
  # The course that this assignment is a part of.
  belongs_to :course, :inverse_of => :assignments
  validates :course, :presence => true
  
  # The user-visible assignment name (e.g., "PSet 1").
  validates :name, :length => 1..64, :uniqueness => { :scope => :course_id },
                   :presence => true
  
  # True if the user is allowed to see this assignment.
  def visible_for?(user)
    user.admin? || assignment.deliverables.any? { |d| d.visible_for? user }
  end

  # A course's assignments, ordered by their deadline.
  scope :by_deadline, order('deadline DESC').order(:name)
  
  # The assignments in a course that are visible to a user.
  def self.for(user, course)
    course.assignments.by_deadline.select { |a| a.visible_for?(user) }
  end
end

# :nodoc: homework submission feature.
class Assignment
  # The time when all the deliverables of the assignment are due.
  validates :deadline, :presence => true, :timeliness => true
  
  # The deliverables that students need to submit to complete the assignment.
  has_many :deliverables, :dependent => :destroy, :inverse_of => :assignment
  accepts_nested_attributes_for :deliverables, :allow_destroy => true,
      :reject_if => lambda { |attributes| attributes[:name].nil? }
        
  # All students' submissions for this assignment.
  has_many :submissions, :through => :deliverables, :inverse_of => :assignment
  
  # The assignment deadline, customized to a specific user.
  #
  # This method will eventually account for deadline extensions. 
  def deadline_for(user)
    deadline
  end
  
  # True if the sumbissions for this assignment should be marked as late.
  #
  # This method takes an user as an argument so that we can later account for
  # deadline extensions.
  def deadline_passed_for?(user)
    deadline < Time.now
  end
  
  # Deliverables that a user can submit files for.
  def deliverables_for(user)
    deliverables.select { |d| d.visible_for? user }
  end
end

# :nodoc: grade collection and publishing feature.
class Assignment
  # The weight of the assignment's score in the overall course score.
  validates :weight, :numericality => { :greater_than_or_equal_to => 0,
      :less_than_or_equal_to => 100, :allow_nil => true }

  # All students' grades for this assignment.
  has_many :grades, :through => :metrics
  
  # The metrics that the students are graded on for this assignment.
  has_many :metrics, :class_name => 'AssignmentMetric', :dependent => :destroy,
                     :inverse_of => :assignment
  accepts_nested_attributes_for :metrics, :allow_destroy => true,
      :reject_if => lambda { |attributes| attributes[:name].nil? }
end

# :nodoc: team integration.
class Assignment
  # The partition of teams used for this assignment.
  belongs_to :team_partition, :inverse_of => :assignments
end

# :nodoc: feedback survey integration.
class Assignment
  # The set of survey questions for getting feedback on this assignment. 
  belongs_to :feedback_survey, :class_name => 'Survey'

  # The questions in the feedback survey for this assignment. 
  def feedback_questions
    # NOTE: this should be a has_many :through association, except ActiveRecord
    #       doesn't support nested :through associations 
    feedback_survey.questions
  end
end

# == Schema Information
#
# Table name: assignments
#
#  id                 :integer(4)      not null, primary key
#  course_id          :integer(4)      not null
#  deadline           :datetime        not null
#  name               :string(64)      not null
#  team_partition_id  :integer(4)
#  feedback_survey_id :integer(4)
#  accepts_feedback   :boolean(1)      default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#

