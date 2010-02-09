# == Schema Information
# Schema version: 20100208065707
#
# Table name: student_infos
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  wants_credit :boolean(1)      not null
#  motivation   :text(16777215)
#  created_at   :datetime
#  updated_at   :datetime
#

class StudentInfo < ActiveRecord::Base
  has_many :recitation_conflicts, :dependent => :destroy
  has_many :prerequisite_answers, :dependent => :destroy
  accepts_nested_attributes_for :prerequisite_answers, :allow_destroy => false
  
  # The user described by this piece of student information.
  belongs_to :user
  # True if the student is taking the class for credit.
  validates_inclusion_of :wants_credit, :in => [true, false]
  # Why is the student taking the class.
  validates_length_of :motivation, :in => 1..(32.kilobytes), :allow_nil => false
end
