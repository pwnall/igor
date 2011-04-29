# == Schema Information
# Schema version: 20110429095601
#
# Table name: survey_answers
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      not null
#  assignment_id :integer(4)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe SurveyAnswer do
  fixtures :survey_answers, :surveys, :assignments, :users
  
  let(:admin) { users(:admin) }
  let(:dexter) { users(:dexter) }
  let(:ps1) { assignments(:ps1) }
  let(:admin_answer) do
    SurveyAnswer.new :user => admin, :assignment => ps1 
  end
  
  it 'should validate properly formed records' do
    admin_answer.should be_valid
  end
  
  describe 'questions' do
    it 'should include all questions for the related survey' do
      admin_answer.should have(5).questions
    end
  end
  
  describe 'create_question_answers' do
    let(:answers) { admin_answer.create_question_answers }
    
    it 'should cover all questions' do
      answers.map(&:question).should =~ admin_answer.questions
    end
    
    it 'should set up the question association' do
      answers.each { |a| a.question.id.should == a.question_id }
    end
    
    it 'should set up target user for user questions' do
      per_user_answers = answers.select { |a| a.question.targets_user? }
      per_user_answers.should have_at_least(1).answer
      per_user_answers.each { |a| a.target_user.should == dexter }
    end
    
    it 'should not set up target user for general questions' do
      general_answers = answers.reject { |a| a.question.targets_user? }
      general_answers.should have_at_least(1).answer
      general_answers.each { |a| a.target_user.should be_nil }
    end
  end
end
