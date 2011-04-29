# == Schema Information
# Schema version: 20110429122654
#
# Table name: team_memberships
#
#  id         :integer(4)      not null, primary key
#  team_id    :integer(4)      not null
#  user_id    :integer(4)      not null
#  created_at :datetime
#

# An association showing that a user belongs to a team.
class TeamMembership < ActiveRecord::Base 
  # The team that the user belongs to.
  belongs_to :team
  validates_presence_of :team
  
  # The user that belongs to a team.
  belongs_to :user, :inverse_of => :team_memberships
  validates :user, :presence => true
  validates :user_id, :uniqueness => { :scope => [:team_id] }
end
