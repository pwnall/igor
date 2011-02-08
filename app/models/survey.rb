# == Schema Information
# Schema version: 20110208012638
#
# Table name: surveys
#
#  id         :integer(4)      not null, primary key
#  name       :string(128)     not null
#  created_at :datetime
#  updated_at :datetime
#

# The set of questions used in a survey.
#
# It's expected that many assignments will use the same set of questions, e.g.
# all psets would use one set of questions, and all projects will use another
# set of questions.
class Survey < ActiveRecord::Base
  # A name for the question set. Visible to admins.
  validates_length_of :name, :in => 1..128, :allow_nil => false
  
  # Memberships for the questions in this set.
  has_many :memberships, :class_name => 'SurveyQuestionMembership',
                         :dependent => :destroy
                         
  # The questions in this set.
  has_many :questions, :through => :memberships, :source => :survey_question
end
