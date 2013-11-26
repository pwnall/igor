# == Schema Information
#
# Table name: grades
#
#  id           :integer          not null, primary key
#  metric_id    :integer          not null
#  grader_id    :integer          not null
#  subject_id   :integer          not null
#  subject_type :string(64)
#  score        :decimal(8, 2)    not null
#  created_at   :datetime
#  updated_at   :datetime
#

class Grade < ActiveRecord::Base
  # The metric that this grade is for.
  belongs_to :metric, class_name: 'AssignmentMetric', inverse_of: :grades
  validates :metric, presence: true,
                     permission: { subject: :grader, can: :grade }
  validates :metric_id, uniqueness: { scope: [:subject_id, :subject_type] }
  #attr_accessible :metric, :metric_id

  # The subject being graded (a user or a team).
  belongs_to :subject, polymorphic: true
  validates :subject, presence: true
  #attr_accessible :subject_type, :subject_id, :subject

  # The user who posted this grade (an admin).
  belongs_to :grader, class_name: 'User'
  validates :grader, presence: true

  # The numeric grade.
  validates_numericality_of :score, only_integer: false
  #attr_accessible :score

  # Because the polymorphic association doesn't allow .where(subject: subject).
  scope :with_subject, lambda { |subject|
    where subject_id: subject.id, subject_type: subject.class.name
  }

  # The users impacted by a grade.
  def users
    subject.respond_to?(:users) ? subject.users : [subject]
  end
end
