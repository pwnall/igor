class CreateSubmissions < ActiveRecord::Migration
  def self.up
    create_table :submissions do |t|
      t.integer :deliverable_id, :null => false
      t.integer :user_id, :null => false

      t.string :code_file_name, :limit => 256
      t.string :code_content_type, :limit => 64
      t.integer :code_file_size
      t.binary :code_file, :limit => 1.megabyte
      t.binary :code_medium_file
      t.binary :code_thumb_file

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
