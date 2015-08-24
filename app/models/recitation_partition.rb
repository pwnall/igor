# == Schema Information
#
# Table name: recitation_partitions
#
#  id            :integer          not null, primary key
#  course_id     :integer          not null
#  section_size  :integer          not null
#  section_count :integer          not null
#  created_at    :datetime
#

# Auto-generated proposal for partitioning students into recitation sections.
class RecitationPartition < ActiveRecord::Base
  # The course whose students and sections are covered by this partition.
  belongs_to :course, inverse_of: :recitation_partitions
  validates :course, presence: true

  # Maximum number of students in a recitation section.
  validates :section_size,
      numericality: { only_integer: true, greater_than: 0 }

  # Number of sections in this assignment.
  validates :section_count,
      numericality: { only_integer: true, greater_than: 0 }

  # Matchings between students and recitation sections.
  has_many :recitation_assignments, dependent: :destroy,
      inverse_of: :recitation_partition
  accepts_nested_attributes_for :recitation_assignments

  # Number of students who don't have a recitation assignment due to conflicts.
  def conflict_count
    course.students.count - recitation_assignments.count
  end

  # Build RecitationAssignment records for a computed assignment.
  #
  # @param [Hash<RecitationSection, Array<Registration>>] section_members maps
  #   each section to the course registrations of the students assigned to it
  def create_assignments(section_members)
    section_members.each do |section, registrations|
      registrations.each do |registration|
        RecitationAssignment.create! user: registration.user,
            recitation_section: section, recitation_partition: self
      end
    end
  end

  def name
    "Proposal #{id}"
  end
end
