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

  # True if "user" should be allowed to see this deliverable.
  def can_read?(user)
    assignment.deliverables_ready? || !!(user && user.admin?)
  end

  # True if "user" should be able to submit (or re-submit) for this deliverable.
  def can_submit?(user)
    assignment.deliverables_ready? || !!(user && user.admin?)
  end

  # This deliverable's submission for the given user.
  #
  # The result is non-trivial in the presence of teams.
  def submission_for(user)
    return nil unless user

    team = assignment.team_partition &&
        assignment.team_partition.team_for_user(user)
    if team.nil?
      submissions.find_by subject: user
    else
      submissions.find_by subject: team
    end
  end

  # The deliverable deadline, customized to a specific user.
  def deadline_for(user)
    assignment.deadline_for user
  end

  # True if the submissions for this deliverable should be marked as late.
  def deadline_passed_for?(user)
    assignment.deadline_passed_for? user
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
