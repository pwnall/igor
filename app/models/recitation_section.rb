# == Schema Information
#
# Table name: recitation_sections
#
#  id         :integer          not null, primary key
#  serial     :integer          not null
#  leader_id  :integer          not null
#  time       :string(64)       not null
#  location   :string(64)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RecitationSection < ActiveRecord::Base
  belongs_to :leader, class_name: 'User', foreign_key: :leader_id
  
  validates_presence_of :leader_id
  validates_presence_of :time
  validates_presence_of :location
  validates_presence_of :serial
  validates_uniqueness_of :serial
  
  
end
