class CreateCheckResults < ActiveRecord::Migration
  def self.up
    create_table :check_results do |t|
      t.integer :submission_id, :null => false
      t.integer :score, :null => true, :default => nil
      t.string :diagnostic, :limit => 256, :null => true, :default => nil
      t.binary :stdout, :limit => 64.kilobytes, :null => true, :default => nil
      t.binary :stderr, :limit => 64.kilobytes, :null => true, :default => nil

      t.timestamps
    end
    
    add_index :check_results, :submission_id, :null => false, :unique => true
  end

  def self.down
    drop_table :check_results
  end
end
