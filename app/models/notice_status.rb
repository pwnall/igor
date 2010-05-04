# == Schema Information
# Schema version: 20100503235401
#
# Table name: notice_statuses
#
#  id        :integer(4)      not null, primary key
#  notice_id :integer(4)      not null
#  user_id   :integer(4)      not null
#  seen      :boolean(1)      not null
#

# TODO(costan): this model is deprecated. Move status functionality to feeditems
#               when materializing them in the database. 
class NoticeStatus < ActiveRecord::Base
  belongs_to :notice
  belongs_to :user
  
  def mark_seen!
    return if self.seen
    
    notice.seen_count += 1
    notice.save!
    
    self.seen = true
    self.save!
  end
end
