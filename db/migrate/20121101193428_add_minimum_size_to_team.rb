class AddMinimumSizeToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :minimum_size, :integer
  end
end
