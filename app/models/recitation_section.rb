# == Schema Information
# Schema version: 20110429095601
#
# Table name: recitation_sections
#
#  id         :integer(4)      not null, primary key
#  serial     :integer(4)      not null
#  leader_id  :integer(4)      not null
#  time       :string(64)      not null
#  location   :string(64)      not null
#  created_at :datetime
#  updated_at :datetime
#

class RecitationSection < ActiveRecord::Base
  belongs_to :leader, :class_name => 'User', :foreign_key => :leader_id
  
  validates_presence_of :leader_id
  validates_presence_of :time
  validates_presence_of :location
  validates_presence_of :serial
  validates_uniqueness_of :serial
  
  
end
