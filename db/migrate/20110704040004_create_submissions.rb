class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.references :deliverable, null: false
      t.references :db_file, null: false
      t.references :subject, polymorphic: true, null: false

      t.timestamps
    end
    
    add_index :submissions, [:subject_id, :subject_type, :deliverable_id], unique: true
    add_index :submissions, [:deliverable_id, :updated_at], unique: false
    add_index :submissions, :updated_at, unique: false
  end  
end
