require 'test_helper'

class TimeSlotAllotmentTest < ActiveSupport::TestCase
  before do
    @allotment = TimeSlotAllotment.new time_slot: time_slots(:m14to15),
        recitation_section: recitation_sections(:r02)
  end

  it 'validates the setup time slot allotment' do
    assert @allotment.valid?
  end

  it 'requires a time slot' do
    @allotment.time_slot = nil
    assert @allotment.invalid?
  end

  it 'forbids allotting a time period to the same recitation multiple times' do
    params = @allotment.attributes
    @allotment.save!
    repetition = TimeSlotAllotment.new params

    assert repetition.invalid?
  end

  it 'requires a recitation' do
    @allotment.recitation_section = nil
    assert @allotment.invalid?
  end

  describe '#time_slot_and_recitation_belong_to_same_course' do
    it 'rejects time slots and recitations from different courses' do
      assert_not_equal time_slots(:m14to15).course, recitation_sections(:r03).course
      @allotment.recitation_section = recitation_sections(:r03)
      assert @allotment.invalid?
    end
  end
end
