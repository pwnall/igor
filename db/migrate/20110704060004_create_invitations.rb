class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :inviter_id
      t.integer :invitee_id
      t.integer :team_id

      t.timestamps null: false
    end
  end
end
