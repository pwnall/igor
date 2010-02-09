# == Schema Information
# Schema version: 20100208065707
#
# Table name: notices
#
#  id              :integer(4)      not null, primary key
#  subject         :string(128)     not null
#  contents        :string(8192)    not null
#  posted_count    :integer(4)      default(0), not null
#  seen_count      :integer(4)      default(0), not null
#  dismissed_count :integer(4)      default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#

class Notice < ActiveRecord::Base
  has_many :notice_statuses, :dependent => :destroy
  
  # posts this notice to all the users' profiles
  def post_to_all_users
    users = User.find(:all)
    reached_users = 0
    users.each do |user|
      notice_status = NoticeStatus.new(:notice => self, :user => user, :seen => false)
      notice_status.save!
      reached_users += 1 
    end
    
    self.posted_count += reached_users
    self.save!
  end
end
