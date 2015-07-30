# == Schema Information
#
# Table name: registrations
#
#  id                    :integer          not null, primary key
#  user_id               :integer          not null
#  course_id             :integer          not null
#  dropped               :boolean          default(FALSE), not null
#  for_credit            :boolean          not null
#  allows_publishing     :boolean          not null
#  recitation_section_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

# A student's commitment to participate in a class.
class Registration < ActiveRecord::Base
  # The student who registered.
  belongs_to :user, inverse_of: :registrations
  validates :user, presence: true

  # The course for which the student registered.
  belongs_to :course, inverse_of: :registrations
  validates :course, presence: true
  validates :course_id, uniqueness: { scope: [:user_id] }

  # True if the student is taking the class for credit.
  validates :for_credit, inclusion: { in: [true, false] }

  # True if the student dropped the class.
  validates :dropped, inclusion: { in: [true, false] }

  # True if the user consents to having their work published.
  validates :allows_publishing, inclusion: { in: [true, false] }

  # The user's recitation section.
  #
  # This is only used if the user is a student and the course has recitations.
  belongs_to :recitation_section

  # Temporary excuse for a calendar.
  has_many :recitation_conflicts, dependent: :destroy, inverse_of: :registration
  accepts_nested_attributes_for :recitation_conflicts
  # Conflicts are destroyed in the UI by submitting a blank class name.
  def destroy_blank_recitation_conflicts
    recitation_conflicts.select { |rc| rc.class_name.blank? }.each(&:destroy)
  end
  private :destroy_blank_recitation_conflicts
  before_validation :destroy_blank_recitation_conflicts

  # Answers to the course's prerequisites questions.
  has_many :prerequisite_answers, dependent: :destroy,
                                  inverse_of: :registration
  accepts_nested_attributes_for :prerequisite_answers, allow_destroy: false

  # Returns true if the given user is allowed to edit this registration.
  def can_edit?(user)
    self.user == user || !!(user && user.admin?)
  end

  # Returns true if the given user is allowed to see this registration.
  def can_view?(user)
    user == self.user || course.is_staff?(user) || !!(user && user.admin?)
  end

  # Populates unanswered prerequisite_answers for a new registration.
  def build_prerequisite_answers
    existing_answers = prerequisite_answers.index_by(&:prerequisite_id)
    course.prerequisites.each do |p|
      next if existing_answers.has_key? p.id
      prerequisite_answers.build prerequisite: p
    end
  end
end
