# == Schema Information
# Schema version: 20100203124712
#
# Table name: assignment_metrics
#
#  id            :integer(4)      not null, primary key
#  name          :string(64)      not null
#  assignment_id :integer(4)      not null
#  max_score     :integer(4)
#  published     :boolean(1)
#  weight        :decimal(16, 8)  default(1.0), not null
#  created_at    :datetime
#  updated_at    :datetime
#

class AssignmentMetric < ActiveRecord::Base
  belongs_to :assignment
end
