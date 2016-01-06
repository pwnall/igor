class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.references :partition, null: false
      t.string :name, limit: 64, null: false

      t.timestamps null: false
    end

    # Prevent duplicate names in a partition.
    add_index :teams, [:partition_id, :name], unique: true
  end
end
