class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      # the deadline (time when the problemset is due)
      t.datetime :deadline, :null => false
      # the assignment name (e.g. Pset 1)
      t.string :name, :limit => 64, :null => false

      # we keep these around for accounting purposes
      t.timestamps
    end
  end

  def self.down
    drop_table :assignments
  end
end
