# == Schema Information
# Schema version: 20100203124712
#
# Table name: deliverables
#
#  id            :integer(4)      not null, primary key
#  assignment_id :integer(4)      not null
#  name          :string(80)      not null
#  description   :string(2048)    not null
#  published     :boolean(1)      not null
#  filename      :string(256)     default(""), not null
#  created_at    :datetime
#  updated_at    :datetime
#

class Deliverable < ActiveRecord::Base
  belongs_to :assignment
  has_one :deliverable_validation, :dependent => :destroy
  has_many :submissions, :dependent => :destroy
end
