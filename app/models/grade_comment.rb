# == Schema Information
#
# Table name: grade_comments
#
#  id         :integer          not null, primary key
#  grade_id   :integer          not null
#  grader_id  :integer          not null
#  comment    :string(4096)     not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# A comment for a grade.
#
# Graders can leave comments to explain their grading. Comments are expected to
# be rare, so they're stored in a separate table to avoid swelling up grade
# records and slowing down stat computations that have to instantiate a lot of
# Grade models.
class GradeComment < ActiveRecord::Base
  # The grade to which this comment applies.
  belongs_to :grade, inverse_of: :comment
  validates :grade, presence: true, uniqueness: true

  # The grader who left this comment.
  belongs_to :grader, class_name: 'User'
  validates :grader, presence: true

  # The comment text.
  # TODO(pwnall): consider allowing safe markdown here.
  validates :comment, presence: true, length: 1..4.kilobytes
end
