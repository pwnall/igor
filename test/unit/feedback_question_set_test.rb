require 'test_helper'

class FeedbackQuestionSetTest < ActiveSupport::TestCase
  test "questions" do
    assert_equal 5, feedback_question_sets(:psets).questions.length,
                 'Pset feedback uses all the questions'
    assert_equal 1, feedback_question_sets(:projects).questions.length,
                 'Projec feedback only cares about hours'
  end
end
