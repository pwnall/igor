# == Schema Information
#
# Table name: prerequisites
#
#  id                  :integer          not null, primary key
#  course_id           :integer          not null
#  prerequisite_number :string(64)       not null
#  waiver_question     :string(256)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

# A prerequisite for a course.
class Prerequisite < ActiveRecord::Base
  # The course that this prerequisite applies to.
  belongs_to :course, inverse_of: :prerequisites
  validates :course, presence: true

  # The course number(s) required for the class.
  #
  # This field can contain multiple numbers, if there are multiple courses
  # satisfying the same prerequisite (e.g. 6.01 / 1.00 could conceivably satisfy
  # a programming prerequisite).
  validates :prerequisite_number, length: 1..64, presence: true,
                                  uniqueness: { scope: :course }

  # Question that students must answer if they haven't taken the prerequisite.
  validates :waiver_question, length: 1..256, presence: true

  # Answers to this prerequisite from all students enrolled in the course.
  has_many :prerequisite_answers, dependent: :destroy,
                                  inverse_of: :prerequisite
end
