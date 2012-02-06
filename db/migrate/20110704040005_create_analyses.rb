class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.references :submission, :null => false
      
      t.integer :score, :null => true, :default => nil
      t.string :diagnostic, :limit => 256, :null => true, :default => nil
      t.binary :stdout, :limit => 64.kilobytes, :null => true, :default => nil
      t.binary :stderr, :limit => 64.kilobytes, :null => true, :default => nil

      t.timestamps
    end
    
    add_index :analyses, :submission_id, :unique => true, :null => false
  end
end
