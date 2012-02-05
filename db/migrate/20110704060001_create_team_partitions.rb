class CreateTeamPartitions < ActiveRecord::Migration
  def change
    create_table :team_partitions do |t|
      t.string :name, :limit => 64, :null => false
      t.boolean :automated, :null => false, :default => true
      t.boolean :editable, :null => false, :default => true
      t.boolean :published, :null => false, :default => false

      t.timestamps
    end
    
    # Enforce name uniqueness.
    add_index :team_partitions, :name, :unique => true, :null => false
  end
end