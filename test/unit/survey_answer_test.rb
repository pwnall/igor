require 'test_helper'

class SurveyAnswerTest < ActiveSupport::TestCase
  setup do
    @answer = SurveyAnswer.new :user => users(:admin),
                               :assignment => assignments(:ps1)
  end
  
  test "setup" do
    assert @answer.valid?
  end
  
  test "questions" do
    assert_equal 5, @answer.questions.length,
                 'Pset feedback uses all the questions'
  end
  
  test "create_question_answers" do
    question_answers = @answer.create_question_answers
    assert_equal Set.new(question_answers.map(&:question)),
                 Set.new(@answer.questions),
                 "Answers don't cover all questions"
                 
    @answer.answers.each do |answer|
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
