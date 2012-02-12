# A student's commitment to participate in a class.
class Registration < ActiveRecord::Base
  # The student who registered.
  belongs_to :user, :inverse_of => :registrations
  validates :user, :presence => true
  
  # The course for which the student registered.
  belongs_to :course, :inverse_of => :registrations
  validates :course, :presence => true
  validates :course_id, :uniqueness => { :scope => [:user_id] }

  # True if the student is taking the class for credit.
  validates :for_credit, :inclusion => { :in => [true, false] }
  attr_accessible :for_credit
  
  # True if the student dropped the class.
  validates :dropped, :inclusion => { :in => [true, false] }
  
  # True if the user consents to having their work published.
  validates :allows_publishing, :inclusion => { :in => [true, false] }  
  attr_accessible :allows_publishing
  
  # The user's recitation section.
  #
  # This is only used if the user is a student and the course has recitations.
  belongs_to :recitation_section
  attr_protected :recitation_section

  # Temporary excuse for a calendar.
  has_many :recitation_conflicts, :dependent => :destroy

  # Answers to the course's prerequisites questions.
  has_many :prerequisite_answers, :dependent => :destroy,
                                  :inverse_of => :registration
  accepts_nested_attributes_for :prerequisite_answers, :allow_destroy => false
  attr_accessible :prerequisite_answers_attributes
  
  # Populates prerequisite_answers for a new registration
  def build_prerequisite_answers
    course.prerequisites.each do |p|
      prerequisite_answers.build :registration => self, :prerequisite => p
    end
  end

  # Returns true if the given user is allowed to edit this registration.
  def can_edit?(user)
    user and (user == self.user or user.admin?)
  end
end

# == Schema Information
#
# Table name: registrations
#
#  id                    :integer(4)      not null, primary key
#  user_id               :integer(4)      not null
#  course_id             :integer(4)      not null
#  dropped               :boolean(1)      default(FALSE), not null
#  teacher               :boolean(1)      default(FALSE), not null
#  for_credit            :boolean(1)      default(TRUE), not null
#  allows_publishing     :boolean(1)      default(TRUE), not null
#  recitation_section_id :integer(4)
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#

