class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.references :submission, :null => false
      
      t.integer :score, :null => true
      t.string :diagnostic, :limit => 256, :null => true

      t.text :log, :limit => 64.kilobytes, :null => true

      t.timestamps
    end
    
    add_index :analyses, :submission_id, :unique => true, :null => false
  end
end
