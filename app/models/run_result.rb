# == Schema Information
# Schema version: 20110208012638
#
# Table name: run_results
#
#  id            :integer(4)      not null, primary key
#  submission_id :integer(4)      not null
#  score         :integer(4)
#  diagnostic    :string(256)
#  stdout        :binary(16777215
#  stderr        :binary(16777215
#  created_at    :datetime
#  updated_at    :datetime
#

class RunResult < ActiveRecord::Base
  belongs_to :submission
end
