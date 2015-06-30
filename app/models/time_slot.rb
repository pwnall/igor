# == Schema Information
#
# Table name: time_slots
#
#  id        :integer          not null, primary key
#  course_id :integer          not null
#  day       :integer          not null
#  starts_at :integer          not null
#  ends_at   :integer          not null
#

# An interval of time during which a recitation takes place.
class TimeSlot < ActiveRecord::Base
  # The course for which this time slot is expected to be reserved.
  belongs_to :course, inverse_of: :time_slots
  validates :course, presence: true

  has_many :time_slot_allotments, inverse_of: :time_slot, dependent: :destroy

  # The recitation scheduling conflicts reported for this time slot.
  has_many :recitation_conflicts, inverse_of: :time_slot, dependent: :destroy

  # The day of the week when this time slot takes place.
  #
  # The week starts on Monday (0), and ends on Sunday (6).
  validates :day, presence: true, numericality: { only_integer: true },
      inclusion: { in: 0..6 }

  # The time at which the time slot begins, in 24-hour notation without a colon.
  #
  # TODO(spark008): The time should be interpreted in the time zone of the
  #   course. All times currently use the app's default configured time zone
  #   (Eastern Time).
  #
  # Eg. 900 is 9:00am (EDT)
  validates :starts_at, numericality: { only_integer: true },
      inclusion: { in: 0...2400 }

  # The start time as a Time-like object (virtual attribute).
  #
  # NOTE: The day of the returned Time object is completely arbitrary and should
  #   not be confused for the day on which the time slot is scheduled. Using a
  #   Time object lets us more easily format the time for views.
  def start_time
    time_at starts_at
  end

  # Set the start time (virtual attribute).
  #
  # @param [Hash<Integer, Integer>] time the time processed through an HTML form
  def start_time=(time)
    self.starts_at = to_database_time time
  end

  # The time at which the time slot ends, in 24-hour notation without a colon.
  #
  # TODO(spark008): The time should be interpreted in the time zone of the
  #   course. All times currently use the app's default configured time zone
  #   (Eastern Time).
  #
  # Eg. 900 is 9:00am (EDT)
  #
  # NOTE: We don't validate that the end time occurs after the start time in
  #   order to support time periods that span across midnight.
  validates :ends_at, uniqueness: { scope: [:course, :day, :starts_at] },
      numericality: { only_integer: true }, inclusion: { in: 0...2400 }

  # The end time as a Time-like object (virtual attribute).
  #
  # NOTE: The day of the returned Time object is completely arbitrary and should
  #   not be confused for the day on which the time slot is scheduled. Using a
  #   Time object lets us more easily format the time for views.
  def end_time
    time_at ends_at
  end

  # Set the end time (virtual attribute).
  #
  # @param [Hash<Integer, Integer>] time the time processed through an HTML form
  def end_time=(time)
    self.ends_at = to_database_time time
  end

  # Convert the time stored in the database into an AS::TimeWithZone instance.
  #
  # @example
  #   time_at(230) #=> Fri, 26 Jun 2015 02:30:00 EDT -04:00
  #
  # @param [Integer] database_time the time in 24-hour notation without a colon
  # @return [ActiveSupport::TimeWithZone] the input as a Time-like object
  def time_at(database_time)
    return unless database_time
    hour, minute = database_time.divmod 100
    Time.zone.parse "#{hour}:#{minute}"
  end
  private :time_at

  # Convert an HTML time form submission into number of minutes since midnight.
  #
  # @example
  #   to_database_time({1=>2015, 2=>6, 3=>26, 4=>18, 5=>30}) #=> 1830
  #
  # @param [Hash<Integer, Integer>] time the time processed through an HTML form
  # @return [Integer] the input time in 24-hour notation without a colon
  def to_database_time(time)
    if time
      time[4] * 100 + time[5]
    else
      nil
    end
  end
  private :to_database_time
end
