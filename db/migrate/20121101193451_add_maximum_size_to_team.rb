class AddMaximumSizeToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :maximum_size, :integer
  end
end
