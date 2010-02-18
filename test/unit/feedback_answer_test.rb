require 'test_helper'

class FeedbackAnswerTest < ActiveSupport::TestCase
  def setup
    @feedback = AssignmentFeedback.new :user => users(:admin),
                                       :assignment => assignments(:ps1)
  end
  
  test "setup" do
    assert @feedback.valid?
  end
  
  test "feedback_answers" do
    assert_equal 5, @feedback.questions.length,
                 'Pset feedback uses all the questions'
  end
  
  test "create_answers" do
    answers = @feedback.create_answers
    assert_equal Set.new(answers.map(&:question)),
                 Set.new(@feedback.questions),
                 "Answers don't cover all questions"
                 
    @feedback.answers.each do |answer|
      assert_equal answer.question.id, answer.question_id,
                   "Answer's question_id doesn't match the question's id"
      if answer.question.targets_user?
        assert_equal users(:dexter), answer.target_user,
                     'Answer to teammate question targets wrong user'
        assert_equal answer.target_user.id, answer.target_user_id,
                     "Answer's target_user_id doesn't match the teammate's id"
      else
        assert_equal nil, answer.target_user,
                     'Answer to assignment-wide question has target user'
      end
    end
  end
end
