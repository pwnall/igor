# == Schema Information
#
# Table name: survey_question_memberships
#
#  id                 :integer          not null, primary key
#  survey_question_id :integer          not null
#  survey_id          :integer          not null
#  created_at         :datetime
#

# Connects survey questions to the sets that they belong to.
class SurveyQuestionMembership < ActiveRecord::Base
  # The question that belongs to a set.
  belongs_to :survey_question
  
  # The set that the question belongs to.
  belongs_to :survey
end
