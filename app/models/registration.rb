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
  has_many :recitation_conflicts, dependent: :destroy
  accepts_nested_attributes_for :recitation_conflicts

  # Answers to the course's prerequisites questions.
  has_many :prerequisite_answers, dependent: :destroy,
                                  inverse_of: :registration
  accepts_nested_attributes_for :prerequisite_answers, allow_destroy: false

  # Returns true if the given user is allowed to edit this registration.
  def can_edit?(user)
    user and (user == self.user or user.admin?)
  end

  # Populates prerequisite_answers for a new registration
  def build_prerequisite_answers
    course.prerequisites.each do |p|
      prerequisite_answers.build registration: self, prerequisite: p
    end
  end

  # new_conflicts is an array of hashes formatted like...
  # [{"timeslot": <integer>, "class_name": <string>},
  #  {"timeslot": 9, "class_name": "6.042"}...]
  def update_conflicts(new_conflicts)
    old_conflicts = recitation_conflicts.index_by(&:timeslot)

    # Update recitation conflicts.
    new_conflicts.each_value do |rc|
      next if rc[:class_name].blank?
      timeslot = rc[:timeslot].to_i
      if old_conflicts.has_key? timeslot
        old_conflicts.delete(timeslot).update_attributes rc
      else
        rc[:registration] = self
        conflict = RecitationConflict.new rc
        recitation_conflicts << conflict
      end
    end
    # Wipe cleared conflicts.
    old_conflicts.each_value do |old_conflict|
      recitation_conflicts.delete old_conflict
    end
  end
end
