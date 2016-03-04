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
  include IsReleased

  # A brief description of the resource. E.g., "PS1 Solutions".
  validates :description, length: 1..64, presence: true

  # The relevant assignment.
  belongs_to :assignment, inverse_of: :files
  validates :assignment, presence: true

  # The course for which this file has been uploaded.
  has_one :course, through: :assignment

  # True if the file's release date has passed.
  def released?
    !!released_at && (released_at < Time.current)
  end

  # True if the given user is allowed to see this file.
  #
  # TODO(spark008): Add checks to this and other model permission methods to
  #     ensure that the user is a student registered for the course.
  def can_read?(user)
    (released? && assignment.released?) || assignment.can_edit?(user)
  end

  # The default release date for a particular resource file.
  #
  # This same method should also be defined for Assignment.
  def default_released_at
    assignment.released_at || self.class.default_released_at
  end
end
