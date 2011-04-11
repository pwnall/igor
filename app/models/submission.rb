# == Schema Information
# Schema version: 20110208012638
#
# Table name: submissions
#
#  id                :integer(4)      not null, primary key
#  deliverable_id    :integer(4)      not null
#  user_id           :integer(4)      not null
#  code_file_name    :string(256)
#  code_content_type :string(64)
#  code_file_size    :integer(4)
#  code_file         :binary(16777215
#  created_at        :datetime
#  updated_at        :datetime
#

# A file submitted by a student for an assignment.
class Submission < ActiveRecord::Base
  # The submitted file (presumably code).
  has_attached_file :code, :storage => :database
  validates_attachment_presence :code
  validates_attachment_size :code, :less_than => 8.megabytes

  # The user doing the submission.
  belongs_to :user, :inverse_of => :submissions
  validates :user, :presence => true
  
  # The deliverable that the submission is for.
  belongs_to :deliverable
  validates :deliverable, :presence => true

  # The assignment that this submission is for.
  has_one :assignment, :through => :deliverable

  # The result of checking the submission.
  has_one :run_result, :dependent => :destroy
end
