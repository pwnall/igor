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

class Grade < ActiveRecord::Base
  # The metric that this grade is for.
  belongs_to :metric, class_name: 'AssignmentMetric', inverse_of: :grades
  validates :metric, presence: true,
                     permission: { subject: :grader, can: :grade }
  validates :metric_id, uniqueness: { scope: [:subject_id, :subject_type] }

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
  validates_each :grader do |record, attr, value|
    next unless record.metric
    unless record.metric.can_grade? value
      record.errors.add attr, "cannot post grades for the metric"
    end
  end

  # The numeric grade.
  validates_numericality_of :score, only_integer: false

  # An optional comment that will be missing on most grades.
  has_one :comment, class_name: 'GradeComment', inverse_of: :grade,
                    dependent: :destroy

  # Because the polymorphic association doesn't allow .where(subject: subject).
  scope :with_subject, lambda { |subject|
    where subject_id: subject.id, subject_type: subject.class.name
  }

  # The users impacted by a grade.
  def users
    subject.respond_to?(:users) ? subject.users : [subject]
  end
end
