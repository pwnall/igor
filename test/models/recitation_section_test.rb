require 'test_helper'

class RecitationSectionTest < ActiveSupport::TestCase
  before do
    @recitation = RecitationSection.new course: courses(:main), serial: 100,
        location: 'my-room'
  end

  let(:recitation) { recitation_sections(:r01) }

  it 'validates the setup recitation' do
    assert @recitation.valid?
  end

  it 'requires a course' do
    @recitation.course = nil
    assert @recitation.invalid?
  end

  it 'requires a serial number' do
    @recitation.serial = nil
    assert @recitation.invalid?
  end

  it 'requires a serial number greater than 0' do
    @recitation.serial = 0
    assert @recitation.invalid?
  end

  it 'forbids duplicate serial numbers within the same course' do
    assert_equal @recitation.course, recitation.course
    @recitation.serial = recitation.serial
    assert @recitation.invalid?
  end

  it 'requires a location' do
    @recitation.location = nil
    assert @recitation.invalid?
  end

  it 'rejects lengthy location names' do
    @recitation.location = 'l' * 65
    assert @recitation.invalid?
  end

  it 'destroys dependent records' do
    assert_equal true, recitation.time_slot_allotments.any?

    recitation.destroy

    assert_empty recitation.time_slot_allotments.reload
  end

  it 'saves associated time slots through the parent recitation' do
    params = { time_slots_attributes: [
      { course: courses(:main), day: 0, starts_at: 0, ends_at: 30 }
    ] }

    assert_difference '@recitation.time_slots.count' do
      @recitation.update! params
    end
  end

  describe '#average_metric_score' do
    let(:metric) { assignment_metrics(:assessment_overall) }
    let(:gradeless_user) { users(:mandark) }

    describe 'some students in the section have no grades' do
      before do
        gradeless_user.registration_for(courses(:main)).update!(
            recitation_section: recitation)
        assert_empty metric.grades.where(subject: gradeless_user)
      end

      it 'returns the average student score for the given metric only, excluding
          students without grades' do
        assert_equal 3, recitation.users.count
        assert_equal 3, metric.grades.count
        assert_equal 2, metric.grades.where(subject: recitation.users).count
        assert_equal (70 + 10) / 2.0, recitation.average_metric_score(metric)
      end
    end

    describe 'none of the students in the section have grades' do
      before { metric.grades.where(subject: recitation.users).destroy_all }

      it 'returns 0' do
        assert_equal 0, recitation.average_metric_score(metric)
      end
    end

    describe 'the section has no students' do
      before do
        recitation.users.each do |u|
          u.registration_for(courses(:main)).update!(recitation_section: nil)
        end
        recitation.users.reload
      end

      it 'returns 0' do
        assert_equal 0, recitation.average_metric_score(metric)
      end
    end
  end
end
