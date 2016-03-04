# == Schema Information
#
# Table name: recitation_sections
#
#  id         :integer          not null, primary key
#  course_id  :integer          not null
#  leader_id  :integer
#  serial     :integer          not null
#  location   :string(64)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Group of students that attend recitation together.
class RecitationSection < ApplicationRecord
  # The course that this section belongs to.
  belongs_to :course, inverse_of: :recitation_sections
  validates :course, presence: true

  # The course staff member leading the section.
  belongs_to :leader, class_name: 'User'

  # Serial number of the section. 1 is displayed as "R01".
  validates :serial, presence: true, numericality: { greater_than: 0 },
                     uniqueness: { scope: :course }

  # Student-friendly description of the section location, e.g. "36-144" (room).
  validates :location, presence: true, length: 1..64

  # Allotments of time slots for this recitation.
  has_many :time_slot_allotments, dependent: :destroy,
      inverse_of: :recitation_section

  # Time slots scheduled for this recitation.
  has_many :time_slots, through: :time_slot_allotments
  accepts_nested_attributes_for :time_slots

  # Course registrations for the students in this section.
  has_many :registrations

  # The students in this section.
  has_many :users, through: :registrations

  # Proposed assignments of students to this recitation section.
  has_many :recitation_assignments
end
