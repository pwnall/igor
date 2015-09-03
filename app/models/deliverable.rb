# == Schema Information
#
# Table name: deliverables
#
#  id            :integer          not null, primary key
#  assignment_id :integer          not null
#  file_ext      :string(16)       not null
#  name          :string(80)       not null
#  description   :string(2048)     not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# The description of a file that students must submit for an assignment.
class Deliverable < ActiveRecord::Base
  # The user-visible deliverable name.
  validates :name, length: 1..64, presence: true,
                   uniqueness: { scope: :assignment }

  # Instructions on preparing submissions for this deliverable.
  validates :description, length: 1..(2.kilobytes), presence: true

  # The extension of files to be submitted for this deliverable. (e.g., "pdf")
  validates :file_ext, length: 1..16, presence: true

  # The assignment that the deliverable is a part of.
  belongs_to :assignment, inverse_of: :deliverables
  validates :assignment, presence: true

  # The method used to verify students' submissions for this deliverable.
  has_one :analyzer, dependent: :destroy, inverse_of: :deliverable
  accepts_nested_attributes_for :analyzer
  validates_associated :analyzer

  # All the student submissions for this deliverable.
  has_many :submissions, dependent: :destroy, inverse_of: :deliverable

  # The course that this deliverable belongs to.
  has_one :course, through: :assignment

  # True if "user" should be allowed to see this deliverable.
  def can_read?(user)
    assignment.deliverables_ready? || course.can_edit?(user)
  end

  # The submission that determines the submitter's grade for this deliverable.
  #
  # The result is non-trivial in the presence of teams.
  #
  # @param [User, Team] submitter the user or team that authored the submission
  # @return [Submission] the submission used to grade the given submitter
  def submission_for_grading(submitter)
    return nil unless submitter

    partition = assignment.team_partition
    author = (partition && partition.team_for_user(submitter)) || submitter
    submissions.where(subject: author).order(:updated_at).last
  end

  # Number of submissions that will be received for this deliverable.
  #
  # The estimation is based on the number of students in the class.
  def expected_submissions
    assignment.course.students.count
  end

  # Queues re-analysis requests for every submission on this deliverable.
  #
  # Calling this will cause a lot of load on the site.
  def reanalyze_submissions
    submissions.includes(:analysis).each do |submission|
      submission.queue_analysis
    end
  end
end
