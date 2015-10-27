# == Schema Information
#
# Table name: assignment_metrics
#
#  id            :integer          not null, primary key
#  assignment_id :integer          not null
#  name          :string(64)       not null
#  max_score     :integer          not null
#  weight        :decimal(16, 8)   not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# A measurable (and measured) result of an assignment.
#
# For example, "the score for Problem 1".
class AssignmentMetric < ActiveRecord::Base
  # The assignment that this metric is for.
  belongs_to :assignment, inverse_of: :metrics
  validates :assignment, presence: true

  # The grades issued for this metric.
  has_many :grades, foreign_key: :metric_id, dependent: :destroy,
                    inverse_of: :metric

  # The comments made for this metric.
  has_many :comments, foreign_key: :metric_id, dependent: :destroy,
      inverse_of: :metric, class_name: 'GradeComment'

  # The user-friendly name for this metric.
  validates :name, length: 1..64, presence: true,
                   uniqueness: { scope: :assignment }

  # The metric's weight when computing the total grade for this assignment.
  #
  # In order to implement a manual 'checkoff' metric that students must earn
  # directly from a course staff member in order to get credit for their auto-
  # graded metric score, create two metrics with the same :max_score, and set
  # the auto-graded metric's weight to 0. This way, the student does not earn
  # their auto-graded score until they defend their score to a staff member in
  # person.
  validates :weight,
      numericality: { greater_than_or_equal_to: 0, allow_nil: false }

  # The maximum score (grade) that can be received on this metric.
  #
  # This score is for display purposes, and it is not enforced.
  #
  # This decision was taken to allow for "bonus" points, e.g. a score of 11 out
  # of 10 for excellent work
  validates :max_score,
      numericality: { greater_than_or_equal_to: 0, allow_nil: false }

  # The course that this metric applies to.
  has_one :course, through: :assignment

  # True if the given user should be allowed to see the metric.
  def can_read?(user)
    assignment.grades_published? || (user && user.admin?)
  end

  # True if the given user should be allowed to post grades for the metric.
  def can_grade?(user)
    course.can_grade? user
  end

  # True if this metric can be destroyed without a warning.
  def safe_to_destroy?
    grades.empty?
  end

  # A user's grade on this assignment metric.
  def grade_for(user)
    subject = assignment.grade_subject_for user
    grade = grades.find_by subject: subject
    return grade unless grade.nil?
    Grade.new metric: self, course: course, subject: subject
  end

  # The average grade dispensed in the given recitation for this metric.
  def grade_for_recitation(recitation)
    grade_total = 0
    students_with_grades = 0

    recitation.users.each do |user|
      next if user.admin?

      grade = grade_for(user)
      next if grade.score.nil?

      grade_total += grade.score
      students_with_grades += 1
    end

    students_with_grades == 0 ? 0 : grade_total / students_with_grades
  end

  # Number of grades that will be posted for this metric.
  #
  # The estimation is based on the number of students in the class.
  def expected_grades
    assignment.course.students.count
  end
end

# :nodoc: score calculations.
class AssignmentMetric
  include AverageScore

  # The weighted maximum score.
  #
  # This value should only be used when calculating an Assignment's total score.
  def weighted_max_score
    max_score * weight
  end

  # The unweighted average grade scored on this metric.
  #
  # Returns 0 if no grades have been assigned for this metric.
  #
  # This same method is defined for Assignment so that the method can be called
  # on either an Assignment or AssignmentMetric instance.
  def average_score
    grades.average(:score) || 0
  end
end
