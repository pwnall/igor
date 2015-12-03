# == Schema Information
#
# Table name: assignment_files
#
#  id            :integer          not null, primary key
#  description   :string(64)       not null
#  assignment_id :integer          not null
#  db_file_id    :integer          not null
#  published_at  :datetime
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
  validates :published_at, timeliness: { type: :datetime, allow_nil: true }

  # Nullify :published_at if the author did not decide a release date.
  def act_on_reset_published_at
    if @reset_published_at
      self.published_at = nil
      @reset_published_at = nil
    end
  end
  private :act_on_reset_published_at
  before_validation :act_on_reset_published_at

  # True if the publish date was omitted (reset to nil) (virtual attribute).
  def reset_published_at
    published_at.nil?
  end

  # Store the user's decision to set or omit (reset) the publish date.
  #
  # @param [String] state '0' if setting a date, '1' if omitting
  def reset_published_at=(state)
    @reset_published_at = ActiveRecord::Type::Boolean.new.cast(state)
  end

  # True if the given user is allowed to see this file.
  #
  # TODO(spark008): Add checks to this and other model permission methods to
  #     ensure that the user is a student registered for the course.
  def can_read?(user)
    (published_at && (published_at < Time.current) && assignment.published?) ||
        assignment.can_edit?(user)
  end
end
