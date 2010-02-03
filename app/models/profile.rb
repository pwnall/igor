# == Schema Information
# Schema version: 18
#
# Table name: profiles
#
#  id                    :integer(4)      not null, primary key
#  user_id               :integer(4)      not null
#  real_name             :string(128)     not null
#  nickname              :string(64)      not null
#  year                  :string(255)     not null
#  athena_username       :string(16)      not null
#  about_me              :string(4096)    default(""), not null
#  has_phone             :boolean(1)      default(TRUE), not null
#  phone_number          :string(64)
#  has_aim               :boolean(1)      not null
#  aim_name              :string(64)
#  has_jabber            :boolean(1)      not null
#  jabber_name           :string(64)
#  recitation_section_id :integer(4)
#  created_at            :datetime
#  updated_at            :datetime
#

class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :recitation_section
  
  validates_presence_of :athena_username
  validates_presence_of :real_name
  validates_presence_of :year
  validates_inclusion_of :year, :in => %w{ 1 2 3 4 G }
  validates_uniqueness_of :user_id
end
