# == Schema Information
#
# Table name: time_slot_allotments
#
#  id                    :integer          not null, primary key
#  time_slot_id          :integer          not null
#  recitation_section_id :integer          not null
#

# The allotment of a time slot to a particular recitation.
class TimeSlotAllotment < ActiveRecord::Base
  # The time slot that is being reserved.
  belongs_to :time_slot, inverse_of: :time_slot_allotments
  validates :time_slot, uniqueness: { scope: :recitation_section },
      presence: true

  # The recitation that takes place during the allotted time.
  belongs_to :recitation_section, inverse_of: :time_slot_allotments
  validates :recitation_section, presence: true

  # Ensures that time slots are allotted to the correct recitations.
  def time_slot_and_recitation_belong_to_same_course
    return unless time_slot && recitation_section
    return if time_slot.course_id == recitation_section.course_id
    errors.add :time_slot, 'should have the same course as the recitation.'
  end
  private :time_slot_and_recitation_belong_to_same_course
  validate :time_slot_and_recitation_belong_to_same_course
end
