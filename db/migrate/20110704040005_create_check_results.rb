class CreateCheckResults < ActiveRecord::Migration
  def change
    create_table :check_results do |t|
      t.references :submission, :null => false
      
      t.integer :score, :null => true, :default => nil
      t.string :diagnostic, :limit => 256, :null => true, :default => nil
      t.binary :stdout, :limit => 64.kilobytes, :null => true, :default => nil
      t.binary :stderr, :limit => 64.kilobytes, :null => true, :default => nil

      t.timestamps
    end
    
    add_index :check_results, :submission_id, :unique => true, :null => false
  end

  def self.down
    drop_table :check_results
  end
end
