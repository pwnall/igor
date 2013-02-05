# == Schema Information
#
# Table name: recitation_sections
#
#  id         :integer          not null, primary key
#  course_id  :integer          not null
#  leader_id  :integer          not null
#  serial     :integer          not null
#  time       :string(64)       not null
#  location   :string(64)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Group of students that attend recitation together.
class RecitationSection < ActiveRecord::Base
  # The course that this section belongs to.
  belongs_to :course
  validates :course, presence: true

  # The course staff member leading the section.
  belongs_to :leader, class_name: 'User'
  validates :leader, presence: true
  accepts_nested_attributes_for :leader

  # Serial number of the section. 1 is displayed as "R01".
  validates :serial, presence: true, numericality: { greater_than: 0 },
                     uniqueness: { scope: [:course_id] }

  # Scheduled time of the recitation. Format: "WF 10am"
  validates :time, presence: true, length: 1..64,
      format: { with: /^[MTWRF]+\d+$/,
      message: 'days of the week followed by the time of day. Ex: MW2, TR10' }

  # Student-friendly description of the section location, e.g. "36-144" (room).
  validates :location, presence: true, length: 1..64

  # Course registrations for the students in this section.
  has_many :registrations

  # The students in this section.
  has_many :users, through: :registrations

  # Proposed assignments of students to this recitation section.
  has_many :recitation_assignments

  validates_presence_of :location

  def recitation_name
    "#{leader.name} #{time}"
  end

  def recitation_days
    days_list = []

    %w[M T W R F].each_with_index do |letter, i|
      days_list << i if time.include? letter
    end

    days_list
  end

  def recitation_time
    rt = time.match(/(\d+)/)[0].to_i
    (rt <= 5) ? rt + 12 : rt
  end

end
