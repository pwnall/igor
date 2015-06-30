require 'test_helper'

class TimeSlotTest < ActiveSupport::TestCase
  before do
    @time_slot = TimeSlot.new course: courses(:main), day: 0, starts_at: 1201,
        ends_at: 1300
  end

  let(:time_slot) { time_slots(:m14to15) }

  it 'validates the setup time slot' do
    assert @time_slot.valid?
  end

  it 'requires a course number' do
    @time_slot.course = nil
    assert @time_slot.invalid?
  end

  it 'requires a day' do
    @time_slot.day = nil
    assert @time_slot.invalid?
  end

  it 'rejects days that are not an integer between 0 and 6 inclusive' do
    @time_slot.day = 10
    assert @time_slot.invalid?
  end

  it 'requires a start time' do
    @time_slot.starts_at = nil
    assert @time_slot.invalid?
  end

  it 'rejects non-integer start times' do
    @time_slot.starts_at = 1.5
    assert @time_slot.invalid?
  end

  it 'requires a start time greater than or equal to 0' do
    @time_slot.starts_at = -1
    assert @time_slot.invalid?
  end

  it 'requires a start time less than 2400' do
    @time_slot.starts_at = 2400
    assert @time_slot.invalid?
  end

  describe '#start_time' do
    it 'returns the start time as a Time-like object' do
      time = @time_slot.start_time
      assert_kind_of Time, time
      assert_equal 12, time.hour
      assert_equal 1, time.min
    end
  end

  describe '#start_time=' do
    it 'sets the :starts_at attribute to the given time' do
      new_time = { 1 => 2015, 2 => 6, 3 => 30, 4 => 23, 5 => 59 }
      @time_slot.update! start_time: new_time
      assert_equal 2359, @time_slot.starts_at
    end
  end

  it 'requires an ending time' do
    @time_slot.ends_at = nil
    assert @time_slot.invalid?
  end

  it 'rejects non-integer end times' do
    @time_slot.ends_at = 1.5
    assert @time_slot.invalid?
  end

  it 'requires an end time greater than or equal to 0' do
    @time_slot.ends_at = -1
    assert @time_slot.invalid?
  end

  it 'requires an end time less than 2400' do
    @time_slot.ends_at = 2400
    assert @time_slot.invalid?
  end

  it 'forbids a course from having duplicate time periods' do
    params = @time_slot.attributes
    duplicate = TimeSlot.new params
    @time_slot.save!

    assert duplicate.invalid?
  end

  it 'destroys dependent records' do
    assert_equal true, time_slot.time_slot_allotments.any?
    assert_equal true, time_slot.recitation_conflicts.any?

    time_slot.destroy

    assert_empty time_slot.recitation_conflicts
    assert_empty time_slot.time_slot_allotments
  end
end
