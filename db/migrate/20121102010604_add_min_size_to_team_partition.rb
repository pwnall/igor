class AddMinSizeToTeamPartition < ActiveRecord::Migration
  def change
    add_column :team_partitions, :min_size, :integer
  end
end
