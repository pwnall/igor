# == Schema Information
# Schema version: 20100502201753
#
# Table name: prerequisite_answers
#
#  id              :integer(4)      not null, primary key
#  student_info_id :integer(4)      not null
#  prerequisite_id :integer(4)      not null
#  took_course     :boolean(1)      not null
#  waiver_answer   :text
#  created_at      :datetime
#  updated_at      :datetime
#

class PrerequisiteAnswer < ActiveRecord::Base
  # The student information containing this answer to a prerequisite question.
  belongs_to :student_info
  # The prerequisite that this answer covers.
  belongs_to :prerequisite
  
  # True if the student took the prerequisite course, false otherwise.
  #
  # NOTE: this is self-reported by the student. We cann't hook up to the
  #       registrar database.
  validates_inclusion_of :took_course, :in => [true, false], :allow_nil => false
  
  # The student's answer to the question which showed up because the student
  # indicated he/she did not take the prerequisite course.
  validates_length_of :waiver_answer, :in => 0...(4.kilobytes),
                      :allow_nil => true  
end
