# == Schema Information
#
# Table name: recitation_student_assignments
#
#  id                                :integer          not null, primary key
#  recitation_assignment_proposal_id :integer          not null
#  user_id                           :integer          not null
#  recitation_section_id             :integer
#  has_conflict                      :boolean          not null
#

class RecitationStudentAssignment < ActiveRecord::Base
  belongs_to :recitation_assignment_proposal, foreign_key: :recitation_assignment_proposal_id
  belongs_to :user
  belongs_to :recitation_section, foreign_key: :recitation_section_id

  validates_presence_of :user_id
  validates_presence_of :recitation_assignment_proposal_id
  validates_inclusion_of :has_conflict, in: [true, false]

  def name
    "#{user.name}"
  end
end
