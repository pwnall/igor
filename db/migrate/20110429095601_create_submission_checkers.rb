class CreateSubmissionCheckers < ActiveRecord::Migration
  def self.up
    create_table :submission_checkers do |t|
      t.string :type, :limit => 32, :null => false
      
      t.integer :deliverable_id, :null => false
      
      t.string :message_name, :limit => 64, :null => true
      t.integer :db_file_id, :null => true
      t.integer :time_limit, :null => true

      t.timestamps
    end
    
    add_index :submission_checkers, :deliverable_id, :null => false,
                                                     :unique => true
  end

  def self.down
    drop_table :submission_checkers
  end
end
