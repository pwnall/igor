class CreateTeamMemberships < ActiveRecord::Migration
  def self.up
    create_table :team_memberships do |t|
      t.integer :team_id, :null => false
      t.integer :user_id, :null => false

      t.datetime :created_at
    end
    # The teams that a user belongs to.
    add_index :team_memberships, [:user_id, :team_id], :unique => true,
                                                       :null => false
    # The users on a team.
    add_index :team_memberships, [:team_id, :user_id], :unique => true,
                                                       :null => false
  end

  def self.down
    drop_table :team_memberships
  end
end
