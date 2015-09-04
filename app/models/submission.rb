# == Schema Information
#
# Table name: submissions
#
#  id             :integer          not null, primary key
#  deliverable_id :integer          not null
#  db_file_id     :integer          not null
#  subject_type   :string           not null
#  subject_id     :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# A file submitted by a student for an assignment.
class Submission < ActiveRecord::Base
  include HasDbFile

  # The user or team doing the submission.
  belongs_to :subject, polymorphic: true, inverse_of: :submissions
  validates :subject, presence: true

  # The deliverable that the submission is for.
  belongs_to :deliverable
  validates :deliverable, presence: true

  # The assignment that this submission is for.
  has_one :assignment, through: :deliverable

  # Diagnostic issued by the deliverable's Analyzer.
  has_one :analysis, dependent: :destroy, inverse_of: :submission

  # Analyzer used to perform an automated health-check for this submission.
  has_one :analyzer, through: :deliverable

  # The course that this homework submission is for.
  has_one :course, through: :deliverable

  # Collaborations with classmates reported for this submission.
  has_many :collaborations, dependent: :destroy, inverse_of: :submission

  # The students who collaborated on this submission.
  has_many :collaborators, through: :collaborations

  # True if the given user is allowed to see the submission.
  def can_read?(user)
    is_owner?(user) || course.can_grade?(user)
  end

  # True if the given user is allowed to remove the submission.
  def can_delete?(user)
    is_owner?(user) || (!!user && user.admin?)
  end

  # True if the given user is allowed to change the submission's metadata.
  #
  # NOTE: In order to maintain a submission history, the submitted file should
  #     never be changed. Metadata, however, can be modified. For example, staff
  #     members can promote submissions if a student wants a different
  #     submission to count toward their grade after the deadline has passed.
  def can_edit?(user)
    is_owner?(user) || course.can_edit?(user)
  end

  # True if the given user is allowed to collaborate on the submission.
  def can_collaborate?(user)
    course.is_student?(user) || course.is_staff?(user)
  end

  # Queues up a request to run an automated health-check for this submission.
  def queue_analysis
    ensure_analysis_exists
    if analyzer
      self.analysis.reset_status! :queued
      self.delay.run_analysis
    else
      self.analysis.reset_status! :no_analyzer
    end
  end

  # Performs an automated health-check for this submission.
  def run_analysis
    ensure_analysis_exists
    if analyzer
      self.analysis.reset_status! :running
      analyzer.analyze self
    else
      self.analysis.reset_status! :no_analyzer
    end
  end

  # After this method completes, this submission's analysis will not be nil.
  def ensure_analysis_exists
    unless analysis
      build_analysis status: :queued, log: ''
    end
  end

  # True if the given user is an owner of this submission.
  #
  # The test is non-trivial when teams come into play.
  def is_owner?(user)
    if subject.instance_of? User
      subject == user
    elsif subject.instance_of? Team
      subject.has_user?(user)
    else
      raise "Unexpected subject type #{subject.class}"
    end
  end

  # Set the collaborators to those of the previous submission used for grading.
  def copy_collaborators_from_previous_submission
    last_submission = deliverable.submission_for_grading subject
    self.collaborators = last_submission.collaborators if last_submission
  end
end
