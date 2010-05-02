# == Schema Information
# Schema version: 20100502201753
#
# Table name: recitation_conflicts
#
#  id              :integer(4)      not null, primary key
#  registration_id :integer(4)      not null
#  class_name      :string(255)     not null
#  timeslot        :integer(4)      not null
#

class RecitationConflict < ActiveRecord::Base
  # The time slot where the registration has a conflict.
  validates_presence_of :timeslot

  # The class invoked to justify this recitation conflict.
  validates_length_of :class_name, :in => 1..64, :allow_nil => false

  # The student registration containing this recitation conflict.
  belongs_to :registration
  validates_presence_of :registration
  validates_uniqueness_of :timeslot, :scope => [:registration_id]
end
