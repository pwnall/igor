class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.references :deliverable, null: false
      t.references :user, null: false
      t.references :db_file, null: false

      t.timestamps
    end
    
    add_index :submissions, [:user_id, :deliverable_id], unique: true
    add_index :submissions, [:deliverable_id, :updated_at], unique: false
    add_index :submissions, :updated_at, unique: false
  end  
end
