# == Schema Information
# Schema version: 18
#
# Table name: submissions
#
#  id                :integer(4)      not null, primary key
#  deliverable_id    :integer(4)      not null
#  user_id           :integer(4)      not null
#  code_file_name    :string(255)
#  code_content_type :string(255)
#  code_file_size    :integer(4)
#  code_updated_at   :datetime
#  code_file         :binary
#  code_medium_file  :binary
#  code_thumb_file   :binary
#  created_at        :datetime
#  updated_at        :datetime
#

# A file submitted by a student for an assignment.
class Submission < ActiveRecord::Base
  # The deliverable that the submission is for.
  belongs_to :deliverable
  # The user doing the submission.
  belongs_to :user
  # The result of checking the submission.
  has_one :run_result, :dependent => :destroy
  # The submitted file (presumably code).
  has_attached_file :code, :storage => :database
  
  validates_presence_of :deliverable
  validates_presence_of :user
  validates_attachment_presence :code
end
