require 'test_helper'

class RecitationConflictTest < ActiveSupport::TestCase
  before do
    @conflict = RecitationConflict.new time_slot: time_slots(:m13to14),
        class_name: 'other-class', registration: registrations(:deedee)
  end

  let(:conflict) { recitation_conflicts(:dexter_6001_monday_1pm) }

  it 'validates the setup recitation conflict' do
    assert @conflict.valid?, @conflict.errors.full_messages
  end

  it 'requires a time slot' do
    @conflict.time_slot = nil
    assert @conflict.invalid?
  end

  it 'should have at most 1 conflict per time slot for 1 registration' do
    @conflict.registration = conflict.registration
    assert @conflict.invalid?
  end

  it 'requires a class name' do
    @conflict.class_name = nil
    assert @conflict.invalid?
  end

  it 'rejects lengthy class names' do
    @conflict.class_name = 'c' * 65
    assert @conflict.invalid?
  end

  it 'requires a registration' do
    @conflict.registration = nil
    assert @conflict.invalid?
  end

  it 'rejects time slots and registrations from different courses' do
    assert_not_equal time_slots(:s10to12).course, registrations(:deedee).course
    @conflict.time_slot = time_slots(:s10to12)
    assert @conflict.invalid?
  end

  it 'validates an associated registration' do
    @conflict.registration = Registration.new
    assert_equal false, @conflict.registration.valid?
    assert_equal false, @conflict.valid?
  end
end
