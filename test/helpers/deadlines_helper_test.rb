require 'test_helper'

class DeadlinesHelperTest < ActionView::TestCase
  include DeadlinesHelper

  describe '#time_delta_in_words' do
    describe 'a time in the past' do
      it "returns the time difference '...ago'" do
        assert_match /\(3 minutes ago\)/, time_delta_in_words(3.minutes.ago)
      end
    end

    describe 'a time in the future' do
      it "returns 'in...' the time difference" do
        assert_match /\(in 3 minutes\)/, time_delta_in_words(3.minutes.from_now)
      end
    end
  end

  describe '#deadline_class' do
    let(:assignment) { assignments(:assessment) }

    describe 'user has an extension for the assignment' do
      it "returns 'inapplicable'" do
        assert_not_nil assignment.extensions.find_by(user: users(:dexter))
        assert_equal 'inapplicable', deadline_class(assignment, users(:dexter))
      end
    end

    describe 'user does not have an extension for the assignment' do
      it "returns 'applicable'" do
        assert_nil assignment.extensions.find_by(user: users(:solo))
        assert_equal 'applicable', deadline_class(assignment, users(:solo))
      end
    end
  end
end
