class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :user, null: false
      t.string :name, limit: 8, null: false
      t.references :course

      t.timestamps
    end

    # List all staff members in a course. Prevent duplicate role entries.
    add_index :roles, [:course_id, :name, :user_id], unique: true
  end
end
