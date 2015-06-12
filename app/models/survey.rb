# == Schema Information
#
# Table name: surveys
#
#  id         :integer          not null, primary key
#  name       :string(128)      not null
#  published  :boolean          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# The set of questions used in a survey.
class Survey < ActiveRecord::Base
  # A name for the question set. Visible to admins.
  validates :name, length: 1..128

  # Whether the survey has been released and users can submit responses.
  validates :published, inclusion: { in: [true, false], allow_nil: false }

  # Memberships for the questions in this set.
  has_many :memberships, class_name: 'SurveyQuestionMembership',
                         dependent: :destroy

  # The questions in this set.
  has_many :questions, through: :memberships, source: :survey_question
end
