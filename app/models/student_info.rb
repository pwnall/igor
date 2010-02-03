# == Schema Information
# Schema version: 18
#
# Table name: student_infos
#
#  id                :integer(4)      not null, primary key
#  user_id           :integer(4)      not null
#  wants_credit      :boolean(1)      not null
#  has_python        :boolean(1)      not null
#  has_math          :boolean(1)      not null
#  python_experience :string(4096)
#  math_experience   :string(4096)
#  comments          :text(16777215)
#  created_at        :datetime
#  updated_at        :datetime
#

class StudentInfo < ActiveRecord::Base
  belongs_to :user
  has_many :recitation_conflicts, :dependent => :destroy
  
  validates_inclusion_of :wants_credit, :in => [true, false]
  validates_inclusion_of :has_python, :in => [true, false]
  validates_inclusion_of :has_math, :in => [true, false]
end
