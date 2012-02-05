class CreateTeamPartitions < ActiveRecord::Migration
  def self.up
    create_table :team_partitions do |t|
      t.string :name, :limit => 64, :null => false
      t.boolean :automated, :null => false, :default => true
      t.boolean :editable, :null => false, :default => true
      t.boolean :published, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :team_partitions
  end
end
