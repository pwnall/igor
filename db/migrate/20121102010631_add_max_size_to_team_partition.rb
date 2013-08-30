class AddMaxSizeToTeamPartition < ActiveRecord::Migration
  def change
    add_column :team_partitions, :max_size, :integer
  end
end
