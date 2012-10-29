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
  
  validates :time, :format => { :with => /^[MTWRF]+\d+$/,
      :message => 'must be days of the week followed by the time of day. Ex: MW2, TR10' }
  
  def recitation_name
    "#{leader.name} - #{time}"
  end

  def recitation_days
    days_list = []

    ['M', 'T', 'W', 'R', 'F'].each_with_index do |letter, i|
      days_list << i if time.include? letter
    end

    days_list
  end

  def recitation_time
    rt = time.match(/(\d+)/).captures[0].to_i
    rt <= 5 ? rt += 12 : rt
  end

end
