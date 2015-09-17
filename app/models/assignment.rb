# == Schema Information
#
# Table name: assignments
#
#  id                 :integer          not null, primary key
#  course_id          :integer          not null
#  author_id          :integer          not null
#  team_partition_id  :integer
#  weight             :decimal(16, 8)   not null
#  name               :string(64)       not null
#  deliverables_ready :boolean          not null
#  metrics_ready      :boolean          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# A piece of work that students have to complete.
#
# Examples: problem set, project, exam.
class Assignment < ActiveRecord::Base
  # The course that this assignment is a part of.
  belongs_to :course, inverse_of: :assignments
  validates :course, presence: true

  # The user-visible assignment name (e.g., "PSet 1").
  validates :name, length: 1..64, uniqueness: { scope: :course },
                   presence: true

  # The user that will be reported as the assignment's author.
  belongs_to :author, class_name: 'User'
  validates :author, presence: true

  # True if components of the assignment have been released.
  def ready?
    deliverables_ready? || metrics_ready?
  end

  # True if the given user is allowed to see this assignment.
  def can_read?(user)
     ready? || can_edit?(user)
  end

  # True if the given user is allowed to submit solutions for this assignment.
  def can_submit?(user)
    (deliverables_ready? && !deadline_passed_for?(user)) || can_edit?(user)
  end

  # True if the given user is allowed to change this assignment.
  def can_edit?(user)
    course.can_edit? user
  end
end

# :nodoc: homework submission feature.
class Assignment
  include HasDeadline

  # If true, students can read deliverables and make submissions.
  #
  # For some assignments, such as exams, that do not have deliverables, this
  # attribute will always remain false.
  validates :deliverables_ready, inclusion: { in: [true, false],
                                              allow_nil: false }

  # The deliverables that students need to submit to complete the assignment.
  has_many :deliverables, dependent: :destroy, inverse_of: :assignment
  validates_associated :deliverables
  accepts_nested_attributes_for :deliverables, allow_destroy: true,
                                               reject_if: :all_blank

  # All students' submissions for this assignment.
  has_many :submissions, through: :deliverables, inverse_of: :assignment

  # Deliverables that the given user can see (not necessarily submit files for).
  def deliverables_for(user)
    (deliverables_ready? || can_edit?(user)) ? deliverables : deliverables.none
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
  #
  # The weight is relative to the weights of all the other assignments in this
  # course. So an assignment of weight 3 is weighed 1.5x as heavily as an
  # assignment of weight 2. If no other assignments are added, the latter
  # assignment will account for 40% of the student's grade.
  validates :weight, numericality: { greater_than_or_equal_to: 0 }

  # If true, students can see their grades on the assignment.
  validates :metrics_ready, inclusion: { in: [true, false], allow_nil: false }

  # The metrics that the students are graded on for this assignment.
  has_many :metrics, class_name: 'AssignmentMetric', dependent: :destroy,
                     inverse_of: :assignment
  validates_associated :metrics
  accepts_nested_attributes_for :metrics, allow_destroy: true,
                                          reject_if: :all_blank

  # All students' grades for this assignment.
  has_many :grades, through: :metrics

  # Resources relevant to this assignment, which students can download.
  has_many :files, inverse_of: :assignment, class_name: 'AssignmentFile',
      dependent: :destroy
  accepts_nested_attributes_for :files, allow_destroy: true

  # The resource files for this assignment that are visible to the given user.
  def files_for(user)
    files.select { |f| f.can_read? user }
  end

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

  # The average score for this assignment given a recitation.
  #
  # This is the sum of all the metrics' recitation averaged scores.
  def recitation_score(recitation)
    metrics.map { |metric| metric.grade_for_recitation recitation }.sum
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
