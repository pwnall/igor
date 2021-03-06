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

# A question that accepts a choice from a range of numbers on a scale.
class QuantitativeScaledQuestion < SurveyQuestion
  # The minimum value on the scale.
  validates :scale_min, numericality: { only_integer: true, allow_nil: false }
  store_accessor :features, :scale_min
  # The maximum value on the scale.
  validates :scale_max, numericality: { only_integer: true, allow_nil: false }
  store_accessor :features, :scale_max

  # User-visible label for the minimum value on the scale.
  validates :scale_min_label, length: { in: 1..64, allow_nil: false }
  store_accessor :features, :scale_min_label
  # User-visible label for the maximum value on the scale.
  validates :scale_max_label, length: { in: 1..64, allow_nil: false }
  store_accessor :features, :scale_max_label

  # Convert strings to numbers.
  def scale_min=(new_value)
    super new_value && new_value.to_i
  end
  def scale_min
    # TODO(pwnall): All the getter overrides can go away if we can make sure
    #               that the database only stores numbers.
    value = super
    value && value.to_i
  end
  def scale_max=(new_value)
    super new_value && new_value.to_i
  end
  def scale_max
    value = super
    value && value.to_i
  end
end
