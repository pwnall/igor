# == Schema Information
#
# Table name: surveys
#
#  id         :integer          not null, primary key
#  name       :string(128)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# The set of questions used in a survey.
#
# It's expected that many assignments will use the same set of questions, e.g.
# all psets would use one set of questions, and all projects will use another
# set of questions.
class Survey < ActiveRecord::Base
  # A name for the question set. Visible to admins.
  validates :name, length: 1..128
  
  # Memberships for the questions in this set.
  has_many :memberships, class_name: 'SurveyQuestionMembership',
                         dependent: :destroy
                         
  # The questions in this set.
  has_many :questions, through: :memberships, source: :survey_question
end
