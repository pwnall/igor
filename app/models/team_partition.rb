# == Schema Information
#
# Table name: team_partitions
#
#  id         :integer          not null, primary key
#  course_id  :integer          not null
#  name       :string(64)       not null
#  min_size   :integer          not null
#  max_size   :integer          not null
#  automated  :boolean          default(TRUE), not null
#  editable   :boolean          default(TRUE), not null
#  released   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# A partitioning of students into teams.
class TeamPartition < ActiveRecord::Base
  # The course using this partitioning.
  belongs_to :course, inverse_of: :team_partitions
  validates :course, presence: true

  # The admin-visible name for the partitioning.
  validates :name, length: 1..64, presence: true, uniqueness: [scope: :course]

  # True if this partitioning is visible to the students.
  validates :released, inclusion: { in: [true, false], allow_nil: false }

  # True if this partitioning was automatically generated. If false, the
  # students are allowed to pair up via a Web UI.
  validates :automated, inclusion: { in: [true, false], allow_nil: false }

  # True if the teams in this partitioning can still be changed.
  validates :editable, inclusion: { in: [true, false], allow_nil: false }

  # The teams in this partitioning.
  has_many :teams, foreign_key: 'partition_id', dependent: :destroy

  # The memberships tying users to the teams in this partitioning.
  has_many :memberships, through: :teams

  # The users assigned to teams by this partitioning.
  has_many :assigned_users, through: :memberships, source: :user

  # The assignments using this partitioning.
  has_many :assignments, dependent: :nullify, inverse_of: :team_partition

  # The deliverables for the assignments using this partitioning.
  has_many :deliverables, through: :assignments

  # The team in this assignment containing a user.
  #
  # Returns nil if the given user isn't contained in any team.
  def team_for_user(user)
    membership = TeamMembership.find_by user: user, team: teams
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
        team = Team.create name: template.team.name, partition: self,
                           course: course
        teams << team
        team_mapping[template.team] = team
      end
      TeamMembership.create(team: team, user: template.user)
    end
    self
  end

  # Automatically assigns users to teams for this partitioning.
  def auto_assign_users(team_size)
    all_registrations = course.registrations.where(for_credit: true).
                               includes(:user).all

    team_sets = []
    overflow = []
    all_registrations.group_by(&:for_credit?).each do |credit, registrations|
      students = registrations.map(&:user).shuffle!
      (0...students.length).step(team_size) do |i|
        team_set = students[i, team_size]
        if team_set.length == team_size
          team_sets << team_set
        else
          overflow += team_set
          if overflow.length >= team_size
            team_sets << overflow.shift(team_size)
          end
        end
      end
    end
    team_sets << overflow

    teams = team_sets.map.with_index do |members, i|
      team = Team.create! partition: self, name: "Team #{i + 1}"
      members.each do |member|
        TeamMembership.create! user: member, team: team, course: course
      end
      team
    end

    teams
  end
end
