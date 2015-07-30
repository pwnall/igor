require 'test_helper'

class SubmissionsHelperTest < ActionView::TestCase
  include SubmissionsHelper

  let(:submission) { submissions(:dexter_assessment) }

  describe '#new_collaboration' do
    let(:invalid_collaboration) do
      Collaboration.new collaborator_email: 'nosuchuser@gmail.com'
    end

    describe 'the previously submitted collaboration was valid' do
      it 'returns a new collaboration' do
        result = new_collaboration(nil, submission)
        assert_instance_of Collaboration, result
        assert_nil result.collaborator_email
      end
    end

    describe 'the invalid collaboration belongs to a different submission' do
      it 'returns a new collaboration' do
        invalid_collaboration.submission = submissions(:dexter_code)
        assert invalid_collaboration.invalid?

        result = new_collaboration(invalid_collaboration, submission)
        assert_instance_of Collaboration, result
        assert_nil result.collaborator_email
      end
    end

    describe 'the invalid collaboration belongs to the submission' do
      it 'returns the invalid collaboration' do
        invalid_collaboration.submission = submission
        assert invalid_collaboration.invalid?

        result = new_collaboration(invalid_collaboration, submission)
        assert_instance_of Collaboration, result
        assert_equal 'nosuchuser@gmail.com', result.collaborator_email
      end
    end
  end
end
