require 'test_helper'

class DeadlineExtensionTest < ActiveSupport::TestCase
  before do
    @extension = DeadlineExtension.new subject: assignments(:assessment),
        user: users(:solo), grantor: users(:main_staff),
        due_at: 1.week.from_now
  end

  let(:extension) { deadline_extensions(:assessment_dexter) }

  it 'validates the setup extension' do
    assert @extension.valid?, @extension.errors.full_messages
  end

  it 'requires a subject' do
    @extension.subject = nil
    assert @extension.invalid?
  end

  it 'requires a user' do
    @extension.user = nil
    assert @extension.invalid?
  end

  it 'forbids a user from having multiple extensions for an assignment' do
    @extension.user = users(:dexter)
    assert @extension.invalid?
  end

  it "requires the user to be registered for the subject's course" do
    @extension.user = users(:inactive)
    assert @extension.invalid?
  end

  it 'requires the grantor to be a course/site admin' do
    @extension.grantor = users(:admin)
    assert @extension.valid?

    @extension.grantor = users(:main_staff)
    assert @extension.valid?

    @extension.grantor = users(:main_grader)
    assert @extension.invalid?

    @extension.grantor = users(:deedee)
    assert @extension.invalid?
  end

  it 'requires a due date' do
    @extension.due_at = nil
    assert @extension.invalid?
  end

  it 'requires the extended deadline to occur after the original deadline' do
    @extension.due_at = assignments(:assessment).due_at - 1.day
    assert @extension.invalid?
  end

  describe '#default_due_at' do
    it "returns the subject's original due date" do
      assert_equal extension.subject.due_at, extension.default_due_at
    end
  end

  describe '#user_exuid' do
    it 'returns the exuid of the user' do
      assert_equal users(:solo).to_param, @extension.user_exuid
    end

    it 'returns nil if the user has not been set' do
      @extension.user = nil
      assert_nil @extension.user_exuid
    end
  end

  describe '#user_exuid=' do
    it 'sets the recipient to the user with the given exuid' do
      @extension.user_exuid = users(:solo).to_param
      assert_equal users(:solo), @extension.user
    end

    it 'sets the recipient to nil if no user with the given exuid exists' do
      nonexistent_exuid = users(:deedee).to_param
      users(:deedee).destroy
      @extension.user_exuid = nonexistent_exuid
      assert_nil @extension.user
    end
  end
end
