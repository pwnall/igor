# == Schema Information
# Schema version: 20100203124712
#
# Table name: assignments
#
#  id         :integer(4)      not null, primary key
#  deadline   :datetime        not null
#  name       :string(64)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Assignment < ActiveRecord::Base
  has_many :deliverables, :dependent => :destroy
  has_many :assignment_metrics, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of :name, :in => 1..64
  validates_uniqueness_of :name
  validates_presence_of :deadline
end
