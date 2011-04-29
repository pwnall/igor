# == Schema Information
# Schema version: 20110429122654
#
# Table name: team_partitions
#
#  id         :integer(4)      not null, primary key
#  name       :string(64)      not null
#  automated  :boolean(1)      default(TRUE), not null
#  editable   :boolean(1)      default(TRUE), not null
#  published  :boolean(1)      not null
#  created_at :datetime
#  updated_at :datetime
#

# A partitioning of students into teams.
class TeamPartition < ActiveRecord::Base
  # True if this partitioning is visible to the students.
  validates :published, :inclusion => { :in => [true, false],
                                       :allow_nil => false }
  
  # True if this partitioning was automatically generated. If false, the
  # students are allowed to pair up via a Web UI.
  validates :automated, :inclusion => { :in => [true, false],
                                       :allow_nil => false }

  # True if the teams in this partitioning can still be changed.
  validates :editable, :inclusion => { :in => [true, false],
                                       :allow_nil => false }

  # The admin-visible name for the partitioning.
  validates :name, :length => 1..64, :presence => true, :uniqueness => true

  # The teams in this partitioning.
  has_many :teams, :foreign_key => 'partition_id', :dependent => :destroy

  # The memberships tying users to the teams in this partitioning.
  has_many :memberships, :through => :teams
  
  # The assignments using this partitioning.
  has_many :assignments, :dependent => :nullify, :inverse_of => :team_partition
  
  # The deliverables for the assignments using this partitioning.
  has_many :deliverables, :through => :assignments
  
  # The team in this assignment containing a user.
  #
  # Returns nil if the given user isn't contained in any team.
  def team_for_user(user)
    membership = TeamMembership.first :conditions => { :user_id => user.id,
        :team_id => teams.map(&:id)}
    membership && membership.team
  end
  
  # The teammates in this assignment for a user.
  def teammates_for_user(user)
    team = team_for_user(user)
    team && (team.users - [user])
  end
  
  # Copies the contents (teams, memberships) of another partition.
  #
  # This offers a quick way of describing a new partition that is similar
  # to an existing partition.
  def populate_from(partition)
    team_mapping = {}
    partition.memberships.includes(:team, :user).each do |template|
      unless team = team_mapping[template.team]
        team = Team.create :name => template.team.name, :partition => self
        teams << team
        team_mapping[template.team] = team
      end
      TeamMembership.create(:team => team, :user => template.user)
    end    
    self
  end

  # Automatically assigns users to teams for this partitioning.
  def auto_assign_users(team_size = 3)
    all_users = User.all(:include => :student_info).
                     reject(&:admin?).select(&:student_info)
    RandomShuffle.shuffle! all_users
    all_teams = []
    all_users.partition { |u| u.student_info.wants_credit }.each do |users|
      leftovers = users.length % team_size
      teams = []
      0.upto(users.length / team_size - 1) do |i|
        team = Team.create! :partition => self,
                            :name => "Team #{all_teams.length + 1}"
        
        users[leftovers + team_size * i, team_size].each do |user|
          TeamMembership.create! :user => user, :team => team
        end
        team.save!
        teams << team
        all_teams << team
      end
      
      if teams.empty?
        team = Team.create! :partition => self,
                            :name => "Team #{all_teams.length + 1}"
        # HACK: all leftover users will be assigned to the team after the if.
        teams = [team] * team_size
        all_teams << team
      end
      
      0.upto(leftovers - 1) do |i|
        TeamMembership.create! :user => users[i], :team => teams[i]
      end
    end
    all_teams
  end  
end
