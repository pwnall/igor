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
end
