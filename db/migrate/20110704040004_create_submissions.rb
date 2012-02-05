class CreateSubmissions < ActiveRecord::Migration
  def self.up
    create_table :submissions do |t|
      t.integer :deliverable_id, :null => false
      t.integer :user_id, :null => false
      t.integer :db_file_id, :null => false

      t.timestamps
    end
    
    add_index :submissions, [:user_id, :deliverable_id], :unique => true
    add_index :submissions, [:deliverable_id, :updated_at], :unique => false
    add_index :submissions, :updated_at, :unique => false
  end  

  def self.down
    drop_table :submissions
  end
end
