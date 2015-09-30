# == Schema Information
#
# Table name: recitation_conflicts
#
#  id              :integer          not null, primary key
#  registration_id :integer          not null
#  time_slot_id    :integer          not null
#  class_name      :string           not null
#

# A scheduling conflict between a recitation assignment and some other course.
class RecitationConflict < ActiveRecord::Base
  # The time slot where the registration has a conflict.
  belongs_to :time_slot, inverse_of: :recitation_conflicts
  validates :time_slot, presence: true, uniqueness: { scope: :registration }

  # The class invoked to justify this recitation conflict.
  validates :class_name, length: { in: 1..64, allow_nil: false }

  # The student registration containing this recitation conflict.
  belongs_to :registration
  validates_each :registration do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.time_slot && (record.time_slot.course_id != value.course_id)
      record.errors.add attr, "should match the time slot's course"
    end
  end

  # TODO(costan): figure out a way to check that the registration is valid
end
