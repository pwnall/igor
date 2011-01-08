# == Schema Information
# Schema version: 20100503235401
#
# Table name: registrations
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  course_id  :integer(4)      not null
#  dropped    :boolean(1)      not null
#  for_credit :boolean(1)      default(TRUE), not null
#  motivation :text(16777215)
#  created_at :datetime
#  updated_at :datetime
#

# A student's commitment to participate in a class.
class Registration < ActiveRecord::Base
  attr_protected :dropped
  
  has_many :recitation_conflicts, :dependent => :destroy
  has_many :prerequisite_answers, :dependent => :destroy
  accepts_nested_attributes_for :prerequisite_answers, :allow_destroy => false
  
  # The student who registered.
  belongs_to :user
  validates_presence_of :user
  # The course for which the student registered.
  belongs_to :course
  validates_uniqueness_of :course_id, :scope => [:user_id], :allow_nil => false
  validates_presence_of :course
  # True if the student is taking the class for credit.
  validates_inclusion_of :for_credit, :in => [true, false]
  # True if the student dropped the class.
  validates_inclusion_of :dropped, :in => [true, false]

  # Why is the student taking the class.
  # TODO(costan): this should be rolled into the registration survey.
  validates_length_of :motivation, :in => 1..(32.kilobytes), :allow_nil => false
  
  # Returns true if the given user is allowed to edit this registration.
  def editable_by_user?(user)
    user and (user == self.user or user.admin?)
  end
end
