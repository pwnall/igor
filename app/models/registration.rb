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
  validates :user, :presence => true
  # The course for which the student registered.
  belongs_to :course
  validates :course, :presence => true
  validates :course_id, :uniqueness => { :scope => [:user_id] }
  # True if the student is taking the class for credit.
  validates :for_credit, :inclusion => { :in => [true, false] }
  # True if the student dropped the class.
  validates :dropped, :inclusion => { :in => [true, false] }

  # Why is the student taking the class.
  # TODO(costan): this should be rolled into the registration survey.
  validates :motivation, :length => 1..(32.kilobytes), :presence => true
  
  # The user's recitation section.
  #
  # This is only used if the user is a student and the course has recitations.
  belongs_to :recitation_section

  # Returns true if the given user is allowed to edit this registration.
  def editable_by_user?(user)
    user and (user == self.user or user.admin?)
  end
end
