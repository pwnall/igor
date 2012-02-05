class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.integer :partition_id, :null => false
      t.string :name, :limit => 64, :null => false

      t.timestamps
    end

    # Prevent duplicate names in a partition.
    add_index :teams, [:partition_id, :name], :unique => true, :null => false
  end

  def self.down
    drop_table :teams
  end
end
