class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :number, limit: 16, null: false
      t.string :title, limit: 256, null: false
      t.string :ga_account, limit: 32, null: true
      t.string :heap_appid, limit: 32, null: true
      t.string :email, limit: 64, null: false
      t.boolean :email_on_role_requests, null: false
      t.boolean :has_recitations, null: false
      t.boolean :has_surveys, null: false
      t.boolean :has_teams, null: false
      t.integer :section_size, null: true

      t.timestamps null: false
    end

    # Enforce course number uniqueness.
    add_index :courses, :number, unique: true
  end
end
