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
  belongs_to :course
  validates_presence_of :course

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

  #
  def create_assignments(inverted_matching)
    sections = RecitationSection.where(course_id: course.id).all
    users = course.users.includes(:profile).all

    inverted_matching.each do |section_number, athena_ids|
      athena_ids.each do |athena_id|
        if section_number == :conflict
          next
        else
          # Convert 24h section time
          section_time =
              section_number > 12 ? section_number - 12 : section_number
          section = sections.find do |s|
            /^[a-zA-Z]+#{section_time}$/ =~ s.time
          end
        end

        user = users.find { |u| u.profile.athena_username == athena_id }
        RecitationAssignment.create! user: user, recitation_section: section,
                                     recitation_partition: self
      end
    end
  end

  def name
    "Proposal #{id}"
  end
end
