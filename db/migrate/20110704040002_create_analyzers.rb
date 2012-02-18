class CreateAnalyzers < ActiveRecord::Migration
  def change
    create_table :analyzers do |t|
      t.references :deliverable, :null => false
      t.string :type, :limit => 32, :null => false
      t.boolean :auto_grading, :null => false, :default => false

      t.string :input_file, :limit => 64, :null => true
      t.text :exec_limits, :limit => 1.kilobyte, :null => true
      t.references :db_file, :null => true

      t.string :message_name, :limit => 64, :null => true

      t.timestamps
    end
    
    add_index :analyzers, :deliverable_id, :unique => true, :null => false
  end
end
