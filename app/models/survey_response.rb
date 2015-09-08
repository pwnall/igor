# == Schema Information
#
# Table name: survey_responses
#
#  id         :integer          not null, primary key
#  course_id  :integer          not null
#  user_id    :integer          not null
#  survey_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# The collection of a student's answers to a survey.
class SurveyResponse < ActiveRecord::Base
  # The student who authored the answers.
  belongs_to :user
  validates_each :user do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.survey && !record.survey.can_respond?(value)
      record.errors.add attr, 'is not allowed to respond to this survey'
    end
  end

  # The survey containing the questions being answered.
  belongs_to :survey
  validates :survey, presence: true, uniqueness: { scope: :user }

  # The course administering the survey.
  belongs_to :course, inverse_of: :survey_responses
  # Get the course, if nil, from the survey.
  def get_survey_course
    self.course ||= survey.course if survey
  end
  private :get_survey_course
  before_validation :get_survey_course

  # Ensures that the course matches the survey's course.
  validates_each :course do |record, attr, value|
    if value.nil?
      record.errors.add attr, 'is not present'
    elsif record.survey && record.survey.course != value
      record.errors.add attr, "does not match the survey's course"
    end
  end

  # The student's answers contained in this response.
  has_many :answers, class_name: 'SurveyAnswer', dependent: :destroy,
      inverse_of: :response, foreign_key: :response_id
  accepts_nested_attributes_for :answers, allow_destroy: true

  # True if the given user is allowed to see this response.
  def can_read?(user)
    (self.user == user) || course.can_edit?(user)
  end

  # True if the given user is allowed to edit this response.
  def can_edit?(user)
    (self.user == user) || !!(user && user.admin?)
  end

  # Populates unanswered survey_questions for a new survey response.
  def build_answers
    existing_answers = answers.index_by &:question_id
    survey.questions.each do |q|
      next if existing_answers.has_key? q.id
      answers.build question: q
    end
  end
end
