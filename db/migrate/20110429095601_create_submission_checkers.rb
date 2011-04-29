class CreateSubmissionCheckers < ActiveRecord::Migration
  def self.up
    create_table :submission_checkers do |t|
      t.string :type, :limit => 32, :null => false

      t.integer :deliverable_id, :null => false
      t.string :message_name, :limit => 64
      
      t.string :pkg_file_name, :limit => 256
      t.string :pkg_content_type, :limit => 64
      t.integer :pkg_file_size
      t.binary :pkg_file, :limit => 64.megabytes
      
      t.integer :time_limit, :default => nil

      t.timestamps
    end
    
    add_index :submission_checkers, :deliverable_id, :null => false,
                                                     :unique => true
  end

  def self.down
    drop_table :submission_checkers
  end
end
