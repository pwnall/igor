# == Schema Information
#
# Table name: recitation_sections
#
#  id         :integer(4)      not null, primary key
#  serial     :integer(4)      not null
#  leader_id  :integer(4)      not null
#  time       :string(64)      not null
#  location   :string(64)      not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class RecitationSection < ActiveRecord::Base
  belongs_to :leader, class_name: 'User', foreign_key: :leader_id
  has_many :registrations
  has_many :users, :through => :registrations
  accepts_nested_attributes_for :leader
  
  validates_presence_of :leader_id
  validates_presence_of :time
  validates_presence_of :location
  validates_presence_of :serial
  validates_uniqueness_of :serial
  
  def recitation_name
    "#{leader.name} - #{time}"
  end
  
end