# == Schema Information
#
# Table name: assignment_files
#
#  id            :integer          not null, primary key
#  description   :string(64)       not null
#  assignment_id :integer          not null
#  db_file_id    :integer          not null
#  released_at   :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Files relevant to an assignment. E.g., test cases, solutions, instructions.
class AssignmentFile < ActiveRecord::Base
  include HasDbFile

  # A brief description of the resource. E.g., "PS1 Solutions".
  validates :description, length: 1..64, presence: true

  # The relevant assignment.
  belongs_to :assignment, inverse_of: :files
  validates :assignment, presence: true

  # The course for which this file has been uploaded.
  has_one :course, through: :assignment

  # The time when this file will be visible to students.
  validates :released_at, timeliness: { type: :datetime, allow_nil: true }

  # Nullify :released_at if the author did not decide a release date.
  def act_on_reset_released_at
    if @reset_released_at
      self.released_at = nil
      @reset_released_at = nil
    end
  end
  private :act_on_reset_released_at
  before_validation :act_on_reset_released_at

  # True if the release date was omitted (reset to nil) (virtual attribute).
  def reset_released_at
    released_at.nil?
  end

  # Store the user's decision to set or omit (reset) the release date.
  #
  # @param [String] state '0' if setting a date, '1' if omitting
  def reset_released_at=(state)
    @reset_released_at = ActiveRecord::Type::Boolean.new.cast(state)
  end

  # True if the given user is allowed to see this file.
  #
  # TODO(spark008): Add checks to this and other model permission methods to
  #     ensure that the user is a student registered for the course.
  def can_read?(user)
    (released_at && (released_at < Time.current) && assignment.released?) ||
        assignment.can_edit?(user)
  end
end
