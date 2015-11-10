# == Schema Information
#
# Table name: survey_questions
#
#  id              :integer          not null, primary key
#  survey_id       :integer          not null
#  prompt          :string(1024)     not null
#  allows_comments :boolean          not null
#  type            :string(32)       not null
#  features        :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# An open-ended question that accepts a single positive number.
class QuantitativeOpenQuestion < SurveyQuestion
  # The granularity for acceptable numerical answers to this question.
  validates :step_size, numericality: { greater_than_or_equal_to: 0,
      less_than: 1000000, allow_nil: false }
  store_accessor :features, :step_size

  # Convert strings to numbers.
  def step_size=(new_value)
    super new_value && new_value.to_f
  end
  def step_size
    # TODO(pwnall): All the getter overrides can go away if we can make sure
    #               that the database only stores numbers.
    value = super
    value && value.to_f
  end
end
