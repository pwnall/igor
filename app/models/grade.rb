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
  # The metric that this grade is for.
  belongs_to :metric, class_name: 'AssignmentMetric', inverse_of: :grades
  validates :metric, uniqueness: { scope: [:subject_id, :subject_type] },
      permission: { subject: :grader, can: :grade }, presence: true

  # The course of the grade's metric.
  #
  # This is redundant, but helps find a student's grades for a specific course.
  belongs_to :course
  validates_each :course do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.metric && record.metric.course != value
      record.errors.add attr, "does not match the metric's course"
    end
  end

  # The subject being graded (a user or a team).
  belongs_to :subject, polymorphic: true
  validates :subject, presence: true

  # The user who posted this grade (on the course staff).
  belongs_to :grader, class_name: 'User'
  validates :grader, presence: true

  # The numeric grade.
  validates_numericality_of :score, only_integer: false

  # An optional comment that will be missing on most grades.
  has_one :comment, class_name: 'GradeComment', inverse_of: :grade,
                    dependent: :destroy

  # The users impacted by a grade.
  def users
    subject.respond_to?(:users) ? subject.users : [subject]
  end
end
