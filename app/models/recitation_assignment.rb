# == Schema Information
#
# Table name: recitation_assignments
#
#  id                      :integer          not null, primary key
#  recitation_partition_id :integer          not null
#  user_id                 :integer          not null
#  recitation_section_id   :integer          not null
#

#
class RecitationAssignment < ActiveRecord::Base
  # The partitioning that that this student assignment is a part of.
  belongs_to :recitation_partition
  validates :recitation_partition, presence: true

  # The student that would be assigned to a section.
  belongs_to :user
  validates :user, presence: true

  # The section that the student would be assigned to.
  belongs_to :recitation_section
  validates :recitation_section, presence: true

  def name
    user.name
  end
end
