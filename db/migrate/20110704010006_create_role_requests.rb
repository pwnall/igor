class CreateRoleRequests < ActiveRecord::Migration
  def change
    create_table :role_requests do |t|
      t.references :user, null: false
      t.string :name, limit: 8, null: false
      t.references :course

      t.timestamps null: false
    end

    # List all requests in a course. Prevent duplicate requests.
    add_index :role_requests, [:course_id, :name, :user_id], unique: true
  end
end
