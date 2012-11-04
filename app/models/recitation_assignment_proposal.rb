# == Schema Information
#
# Table name: recitation_assignment_proposals
#
#  id                    :integer          not null, primary key
#  course_id             :integer          not null
#  recitation_size       :integer          not null
#  number_of_recitations :integer          not null
#  number_of_conflicts   :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class RecitationAssignmentProposal < ActiveRecord::Base
  validates_presence_of :course_id
  validates :recitation_size, numericality: { only_integer: true, greater_than: 0 }
  validates :number_of_recitations, numericality: { only_integer: true, greater_than: 0 }
  validates :number_of_conflicts, numericality: { greater_than_or_equal_to: 0 }

  has_many :recitation_student_assignments, dependent: :destroy, inverse_of: :recitation_assignment_proposal
  accepts_nested_attributes_for :recitation_student_assignments

  def create_student_assignments reverted_matching
    reverted_matching.each do |section, students|
      students.each do |student|
        if section == :conflict
          rec_sec_id = nil
          conflict = 1
        else
          # Convert 24h section time
          section_time = section > 12 ? section - 12 : section
          rec_sec_id = RecitationSection.find(:all, conditions: ['time LIKE ?', "%#{section_time}"]).first.id
          conflict = 0
        end

        user = User.joins(:profile).where(profiles: { athena_username: student }).first
        rsa = RecitationStudentAssignment.new user_id: user.id,
                                           recitation_section_id: rec_sec_id,
                                           recitation_assignment_proposal_id: id,
                                           has_conflict: conflict
        rsa.save
      end
    end
  end

  def name
    "Proposal #{id}"
  end
end
