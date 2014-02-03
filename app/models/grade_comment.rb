# A comment for a grade.
#
# Graders can leave comments to explain their grading. Comments are expected to
# be rare, so they're stored in a separate table to avoid swelling up grade
# records and slowing down stat computations that have to instantiate a lot of
# Grade models.
class GradeComment < ActiveRecord::Base
  # The grade that this comment applies to.
  belongs_to :grade, inverse_of: :comment
  validates :grade, presence: true

  # The grader who left this comment.
  belongs_to :grader, class_name: 'User'
  validates :grader, presence: true

  # The comment text.
  # TODO(pwnall): consider allowing safe markdown here.
  validates :comment, presence: true, length: 1..4.kilobytes
end
