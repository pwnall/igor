class CreateTeamMemberships < ActiveRecord::Migration
  def change
    create_table :team_memberships do |t|
      t.references :team, null: false
      t.references :user, null: false
      t.references :course, null: false

      t.datetime :created_at

      # Ensure no duplicates.
      t.index [:user_id, :team_id], unique: true
      # The users on a team.
      t.index [:team_id, :user_id], unique: true
      # All the user's teams for a course.
      t.index [:user_id, :course_id]
    end
  end
end
