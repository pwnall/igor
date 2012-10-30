class Invitation < ActiveRecord::Base
  attr_accessible :invitee_id, :team_id, :inviter_id
end