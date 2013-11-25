# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  inviter_id :integer
#  invitee_id :integer
#  team_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Invitation < ActiveRecord::Base
  attr_accessible :invitee_id, :team_id, :inviter_id
end
