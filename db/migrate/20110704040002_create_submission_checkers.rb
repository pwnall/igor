class CreateSubmissionCheckers < ActiveRecord::Migration
  def change
    create_table :submission_checkers do |t|
      t.references :deliverable, :null => false

      t.references :db_file, :null => true            
      t.integer :time_limit, :null => true
      
      t.string :message_name, :limit => 64, :null => true

      t.string :type, :limit => 32, :null => false

      t.timestamps
    end
    
    add_index :submission_checkers, :deliverable_id, :null => false,
                                                     :unique => true
  end
end
