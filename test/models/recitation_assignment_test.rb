require 'test_helper'

class RecitationAssignmentTest < ActiveSupport::TestCase
  before do
    @recitation_assignment = RecitationAssignment.new user: users(:mandark),
        recitation_partition: recitation_partitions(:main),
        recitation_section: recitation_sections(:r02)
  end

  it 'validates the setup assignment' do
    assert @recitation_assignment.valid?
  end

  it 'requires a partition' do
    @recitation_assignment.recitation_partition = nil
    assert @recitation_assignment.invalid?
  end

  it 'requires a user' do
    @recitation_assignment.user = nil
    assert @recitation_assignment.invalid?
  end

  it 'forbids users from belonging to multiple sections within a partition' do
    assert_not_nil recitation_partitions(:main).recitation_assignments.
        find_by(user: users(:deedee))
    @recitation_assignment.user = users(:deedee)
    assert @recitation_assignment.invalid?
  end

  it 'requires a section' do
    @recitation_assignment.recitation_section = nil
    assert @recitation_assignment.invalid?
  end

  it 'requires the section and partition to belong to the same course' do
    @recitation_assignment.recitation_section = recitation_sections(:r03)
    assert @recitation_assignment.invalid?
  end
end
