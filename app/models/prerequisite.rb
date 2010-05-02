# == Schema Information
# Schema version: 20100502201753
#
# Table name: prerequisites
#
#  id              :integer(4)      not null, primary key
#  course_number   :string(64)      not null
#  waiver_question :string(256)     not null
#  created_at      :datetime
#  updated_at      :datetime
#

# A prerequisite for the course.
class Prerequisite < ActiveRecord::Base
  has_many :prerequisite_answers, :dependent => :destroy
  
  # The course number(s) required for the class.
  #
  # This field can contain multiple numbers, if there are multiple courses
  # satisfying the same prerequisite (e.g. 6.01 / 1.00 could conceivably satisfy
  # a programming prerequisite).
  validates_length_of :course_number, :allow_nil => false, :in => 1..64
  
  # The text for a question that students must answer if they indicate they
  # haven't taken the required course.
  validates_length_of :waiver_question, :allow_nil => false, :in => 1..256
end
