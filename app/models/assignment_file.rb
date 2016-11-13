# == Schema Information
#
# Table name: assignment_files
#
#  id                 :integer          not null, primary key
#  description        :string(64)       not null
#  assignment_id      :integer          not null
#  file_blob_id       :string(48)       not null
#  file_size          :integer          not null
#  file_mime_type     :string(64)       not null
#  file_original_name :string(256)      not null
#  released_at        :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# Wraps a file relevant to an assignment.
#
# Examples include the assignment description, solutions, and test cases.
class AssignmentFile < ApplicationRecord
  include IsReleased

  # A brief description of the resource. E.g., "PS1 Solutions".
  validates :description, length: 1..64, presence: true

  # The wrapped file.
  has_file_blob :file, allows_nil: false, blob_model: 'FileBlob'

  # Refuse to serve active content from the site.
  validates :file_mime_type, exclusion: {
      in: ['text/html', 'application/xhtml+xml'] }

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
    (released? && assignment.released_for_student?(user)) ||
        assignment.can_edit?(user)
  end

  # The default release date for a particular resource file.
  #
  # This same method should also be defined for Assignment.
  def default_released_at
    assignment.released_at || self.class.default_released_at
  end
end
