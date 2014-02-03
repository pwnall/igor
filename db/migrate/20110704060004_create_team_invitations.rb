class CreateTeamInvitations < ActiveRecord::Migration
  def change
    create_table :team_invitations do |t|
      t.integer :inviter_id
      t.integer :invitee_id
      t.integer :team_id

      t.timestamps
    end
  end
end
