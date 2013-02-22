# == Schema Information
#
# Table name: recitation_conflicts
#
#  id              :integer          not null, primary key
#  registration_id :integer          not null
#  timeslot        :integer          not null
#  class_name      :string(255)      not null
#

class RecitationConflict < ActiveRecord::Base
  # The time slot where the registration has a conflict.
  validates_presence_of :timeslot

  # The class invoked to justify this recitation conflict.
  validates_length_of :class_name, in: 1..64, allow_nil: false

  # The student registration containing this recitation conflict.
  belongs_to :registration
  
  # TODO(costan): figure out a way to check that the registration is valid
  #validates_presence_of :registration_id
  #validates_uniqueness_of :timeslot, :scope => [:registration_id]
end
