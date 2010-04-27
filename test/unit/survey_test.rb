require 'test_helper'

class SurveySetTest < ActiveSupport::TestCase
  test "questions" do
    assert_equal 5, surveys(:psets).questions.length,
                 'Pset feedback survey uses all the questions'
    assert_equal 1, surveys(:projects).questions.length,
                 'Project feedback survey only cares about hours'
  end
end
