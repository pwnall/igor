class CreateRunResults < ActiveRecord::Migration
  def self.up
    create_table :run_results do |t|
      # the submission that this run is coupled to
      t.integer :submission_id, :null => false
      # the score obtained in this run
      t.integer :score, :null => true, :default => nil
      # a diagnostic string to show the user
      t.string :diagnostic, :limit => 256, :null => true, :default => nil
      # the contents of the stdandard output produced by this run 
      t.binary :stdout, :limit => 64.kilobytes, :null => true, :default => nil
      # the contents of the stdandard error produced by this run 
      t.binary :stderr, :limit => 64.kilobytes, :null => true, :default => nil

      # audit / diagnostics
      t.timestamps
    end
    
    add_index :run_results, :submission_id, :unique => true
  end

  def self.down
    remove_index :run_results, :submission_id
    drop_table :run_results
  end
end
