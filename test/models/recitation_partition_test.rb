require 'test_helper'

class RecitationPartitionTest < ActiveSupport::TestCase
  before do
    @partition = RecitationPartition.new course: courses(:main),
        section_size: 10, section_count: 5
  end

  let(:partition) { recitation_partitions(:main) }

  it 'validates the setup partition' do
    assert @partition.valid?
  end

  it 'requires a course' do
    @partition.course = nil
    assert @partition.invalid?
  end

  it 'requires a section size' do
    @partition.section_size = nil
    assert @partition.invalid?
  end

  it 'rejects non-integer section sizes' do
    @partition.section_size = 9.5
    assert @partition.invalid?
  end

  it 'rejects non-positive section sizes' do
    @partition.section_size = 0
    assert @partition.invalid?
  end

  it 'requires a section size' do
    @partition.section_count = nil
    assert @partition.invalid?
  end

  it 'rejects non-integer section sizes' do
    @partition.section_count = 9.5
    assert @partition.invalid?
  end

  it 'rejects non-positive section sizes' do
    @partition.section_count = 0
    assert @partition.invalid?
  end

  it 'destroys dependent records' do
    assert_not_empty partition.recitation_assignments

    partition.destroy

    assert_empty partition.recitation_assignments
  end
end
