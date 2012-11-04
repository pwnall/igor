class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :number, limit: 16, null: false
      t.string :title, limit: 256, null: false      
      t.string :ga_account, limit: 32, null: false
      t.string :email, limit: 64, null: false
      t.boolean :has_recitations, null: false, default: true
      t.boolean :has_surveys, null: false, default: true
      t.boolean :has_teams, null: false, default: true
      t.integer :recitation_size, default: 20

      t.timestamps
    end
    
    # Enforce course number uniqueness.
    add_index :courses, :number, unique: true, null: false
  end
end
