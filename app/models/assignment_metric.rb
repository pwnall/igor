# == Schema Information
#
# Table name: assignment_metrics
#
#  id            :integer          not null, primary key
#  assignment_id :integer          not null
#  name          :string(64)       not null
#  max_score     :integer          not null
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

  # The user-friendly name for this metric.
  validates :name, length: 1..64, presence: true,
                   uniqueness: { scope: :assignment }

  # The maximum score (grade) that can be received on this metric.
  #
  # This score is for display purposes, and it is not enforced.
  #
  # This decision was taken to allow for "bonus" points, e.g. a score of 11 out
  # of 10 for excellent work
  validates :max_score, numericality: { greater_than_or_equal_to: 0 },
                        presence: true

  # The course that this metric applies to.
  has_one :course, through: :assignment

  # True if the given user should be allowed to see the metric.
  def can_read?(user)
    assignment.metrics_ready? || (user && user.admin?)
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
