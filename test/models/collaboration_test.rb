require 'test_helper'

class CollaborationTest < ActiveSupport::TestCase
  before do
    @collaboration = Collaboration.new collaborator: users(:dexter),
        submission: submissions(:dexter_assessment)
  end

  let(:collaboration) { collaborations(:deedee_on_dexter_assessment) }

  it 'validates the setup collaboration' do
    assert @collaboration.valid?
  end

  it 'requires a submission' do
    @collaboration.submission = nil
    assert @collaboration.invalid?
  end

  it 'requires a collaborator' do
    @collaboration.collaborator = nil
    assert @collaboration.invalid?
  end

  it 'forbids a collaborator from being listed twice for the same submission' do
    @collaboration.collaborator = users(:deedee)
    assert @collaboration.invalid?
  end

  describe ':collaborator_email virtual attribute' do
    describe 'a user record with that e-mail address exists' do
      before { @collaboration.update! collaborator_email: users(:solo).email }

      it 'returns the e-mail address' do
        assert_equal 'costan+solo@mit.edu', @collaboration.collaborator_email
      end

      it 'requires the collaborator to be registered for the course' do
        registrations(:solo).destroy
        assert @collaboration.invalid?
      end
    end

    describe 'no user record with that e-mail address exists' do
      it 'returns the e-mail address, if it is not nil' do
        @collaboration.collaborator_email = 'nosuchuser@gmail.com'
        assert_equal 'nosuchuser@gmail.com', @collaboration.collaborator_email
        assert @collaboration.invalid?
      end

      it 'returns nil, if the e-mail address is nil' do
        @collaboration.collaborator_email = nil
        assert_nil @collaboration.collaborator_email
        assert @collaboration.invalid?
      end
    end
  end
end
