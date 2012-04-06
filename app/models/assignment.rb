# A piece of work that students have to complete.
#
# Examples: problem set, project, exam.
class Assignment < ActiveRecord::Base
  # The course that this assignment is a part of.
  belongs_to :course, inverse_of: :assignments
  validates :course, presence: true
  
  # The user-visible assignment name (e.g., "PSet 1").
  validates :name, length: 1..64, uniqueness: { scope: :course_id },
                   presence: true
  attr_accessible :name
  
  # The user that will be reported as the assignment's author.
  belongs_to :author, class_name: 'User'
  attr_accessible :author
  validates :author, presence: true
  attr_accessible :author_id
  
  # True if the user is allowed to see this assignment.
  def can_read?(user)
    deliverables_ready? || metrics_ready? || (user && user.admin?)
  end

  # Adds deadline ordering to an assignment query.
  scope :by_deadline, order('deadline DESC').order(:name)
  
  # The assignments in a course that are visible to a user.
  def self.for(user, course)
    course.assignments.by_deadline.select { |a| a.can_read? user }
  end
end

# :nodoc: homework submission feature.
class Assignment
  # The time when all the deliverables of the assignment are due.
  validates :deadline, presence: true, timeliness: true
  attr_accessible :deadline
  
  # If true, students can read deliverables and make submissions.
  validates :deliverables_ready, inclusion: { in: [true, false],
                                              allow_nil: false }
  attr_accessible :deliverables_ready

  # The deliverables that students need to submit to complete the assignment.
  has_many :deliverables, dependent: :destroy, inverse_of: :assignment
  validates_associated :deliverables
  accepts_nested_attributes_for :deliverables, allow_destroy: true,
                                               reject_if: :all_blank
  attr_accessible :deliverables_attributes

  # All students' submissions for this assignment.
  has_many :submissions, through: :deliverables, inverse_of: :assignment
  
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
    deadline_for(user) < Time.now
  end
  
  # Deliverables that a user can submit files for.
  def deliverables_for(user)
    (deliverables_ready? || (user && user.admin?)) ? deliverables : []
  end
  
  # Number of submissions that will be received for this assignment.
  #
  # The estimation is based on the number of students in the class.
  def expected_submissions
    deliverables.count * course.students.count
  end
end

# :nodoc: grade collection and publishing feature.
class Assignment
  # The assignment's weight when computing total class scores.
  validates :weight, numericality: { greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100, allow_nil: true }
  attr_accessible :weight
  
  # If true, students can see their grades on the assignment.
  validates :metrics_ready, inclusion: { in: [true, false], allow_nil: false }
  attr_accessible :metrics_ready
  
  # The metrics that the students are graded on for this assignment.
  has_many :metrics, class_name: 'AssignmentMetric', dependent: :destroy,
                     inverse_of: :assignment
  validates_associated :metrics
  accepts_nested_attributes_for :metrics, allow_destroy: true,
                                          reject_if: :all_blank
  attr_accessible :metrics_attributes
  
  # All students' grades for this assignment.
  has_many :grades, through: :metrics
  
  # Number of submissions that will be received for this assignment.
  #
  # The estimation is based on the number of students in the class.
  def expected_grades
    metrics.count * course.students.count
  end
  
  # The maximum score that a student can obtain on this assignment.
  #
  # This is the sum of all the metrics' maximum scores.
  def max_score
    metrics.sum :max_score
  end  
end

# :nodoc: lifecycle
class Assignment
  # This assignment's position in the assignment lifecycle.
  # 
  # :draft -- under construction, not available to students
  # :open -- the assignment accepts submissions from students
  # :grading -- the assignment doesn't accept submissions, grades are not ready
  # :graded -- grades have been released to students
  def ui_state_for(user)
    if metrics_ready?
      :graded
    elsif deliverables_ready?
      if deadline_passed_for? user
        :grading
      else
        (deliverables.length > 0) ? :open : :grading
      end
    else
      :draft
    end
  end
end

# :nodoc: team integration.
class Assignment
  # The partition of teams used for this assignment.
  belongs_to :team_partition, inverse_of: :assignments
  
  # The object to be set as the subject on this assignment's grades for a user.
  def grade_subject_for(user)
    team_partition.nil? ? user : team_partition.team_for_user(user)
  end
end

# :nodoc: feedback survey integration.
class Assignment
  # The set of survey questions for getting feedback on this assignment. 
  belongs_to :feedback_survey, class_name: 'Survey'

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
#  author_id          :integer(4)      not null
#  team_partition_id  :integer(4)
#  feedback_survey_id :integer(4)
#  deadline           :datetime        not null
#  weight             :decimal(16, 8)  default(1.0), not null
#  name               :string(64)      not null
#  deliverables_ready :boolean(1)      default(FALSE), not null
#  metrics_ready      :boolean(1)      default(FALSE), not null
#  accepts_feedback   :boolean(1)      default(FALSE), not null
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

