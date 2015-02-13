# == Schema Information
#
# Table name: recitation_sections
#
#  id         :integer          not null, primary key
#  course_id  :integer          not null
#  leader_id  :integer
#  serial     :integer          not null
#  time       :string(64)       not null
#  location   :string(64)       not null
#  created_at :datetime
#  updated_at :datetime
#

# Group of students that attend recitation together.
class RecitationSection < ActiveRecord::Base
  # The course that this section belongs to.
  belongs_to :course, inverse_of: :recitation_sections
  validates :course, presence: true

  # The course staff member leading the section.
  belongs_to :leader, class_name: 'User'

  # Serial number of the section. 1 is displayed as "R01".
  validates :serial, presence: true, numericality: { greater_than: 0 },
                     uniqueness: { scope: [:course_id] }

  # Scheduled time of the recitation. Format: "WF 10am"
  validates :time, presence: true, length: 1..64,
      format: { with: /\A[MTWRF]+\d+\Z/,
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
    if location.blank?
      "#{time} #{leader.name}"
    else
      "#{time} #{location} #{leader.name}"
    end
  end

  # Section meeting times, in the same format as the registration schedule.
  #
  # @return [Array<Number>] meeting times, where each meeting time is
  #   10 * hour_index + day_index; hour_index is 24-based and day_index is
  #   0-based starting on Monday, e.g. 141 is 2pm, Tuesday.
  def timeslots
    return @timeslots if @timeslots

    # Decode MIT schedule notation, e.g. MR4
    #
    # Simplifying assumptions:
    # * recitations last one hour, so we won't have times like M1-2:30
    # * recitations happen the same time each day, so we won't have times like
    #   M1,R3
    # * times 1-7 are pm, everything else is am; there are no classes before
    #   8am, and 7-9pm is reserved for varsity sports, so there shouldn't be
    #   recitations at or after 7pm
    #
    # There's no point in writing a better parser. The effort should be spent
    # on migrating away from the MIT-specific syntax.
    #
    # TODO(pwnall): this should go away and be replaced by a generic UI that
    #               any school instructor can understand and work with
    days_list = []
    %w[M T W R F].each_with_index do |letter, i|
      days_list << i if time.include? letter
    end
    time_index = time.match(/(\d+)/)[0].to_i
    time_index += 12 if time_index <= 7

    @timeslots = days_list.map { |day_index| time_index * 10 + day_index }
  end

  # :nodoc: invalida @timeslots when a new time is assigned
  def time=(new_value)
    @timeslots = nil
    super
  end
end
