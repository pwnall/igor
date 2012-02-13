class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.references :submission, :null => false
      t.integer :status_code, :null => false
      t.integer :score, :null => true
      
      t.text :log, :limit => 64.kilobytes, :null => false, :default => ''

      t.timestamps
    end
    
    add_index :analyses, :submission_id, :unique => true, :null => false
  end
end
