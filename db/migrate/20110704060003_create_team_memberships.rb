class CreateTeamMemberships < ActiveRecord::Migration
  def change
    create_table :team_memberships do |t|
      t.references :team, :null => false
      t.references :user, :null => false

      t.datetime :created_at
    end
    
    # The teams that a user belongs to.
    add_index :team_memberships, [:user_id, :team_id], :unique => true,
                                                       :null => false
    # The users on a team.
    add_index :team_memberships, [:team_id, :user_id], :unique => true,
                                                       :null => false
  end
end
