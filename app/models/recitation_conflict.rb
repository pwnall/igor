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
  validates_length_of :class_name, in: 1..64, allow_nil: false

  # The student registration containing this recitation conflict.
  belongs_to :registration
  validates :registration, presence: true

  # Ensures that conflicts are being reported for the correct time slots.
  def time_slot_and_registration_belong_to_same_course
    return unless time_slot && registration
    return if time_slot.course_id == registration.course_id
    errors.add :time_slot, 'should have the same course as the registration.'
  end
  private :time_slot_and_registration_belong_to_same_course
  validate :time_slot_and_registration_belong_to_same_course

  # TODO(costan): figure out a way to check that the registration is valid
end
