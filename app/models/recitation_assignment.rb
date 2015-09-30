# == Schema Information
#
# Table name: recitation_assignments
#
#  id                      :integer          not null, primary key
#  recitation_partition_id :integer          not null
#  user_id                 :integer          not null
#  recitation_section_id   :integer          not null
#

# Associates a user with a recitation section in an assignment proposal.
class RecitationAssignment < ActiveRecord::Base
  # The partitioning that that this student assignment is a part of.
  belongs_to :recitation_partition
  validates :recitation_partition, presence: true

  # The student that would be assigned to a section.
  belongs_to :user
  validates :user, presence: true, uniqueness: { scope: :recitation_partition }

  # The section that the student would be assigned to.
  belongs_to :recitation_section
  validates_each :recitation_section do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.recitation_partition &&
        (record.recitation_partition.course_id != value.course_id)
      record.errors.add attr, "should match the partition's course"
    end
  end
end
