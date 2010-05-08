class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.datetime :deadline, :null => false
      t.string :name, :limit => 64, :null => false
      t.integer :team_partition_id, :null => true
      t.integer :feedback_survey_id, :null => true
      t.boolean :accepts_feedback, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :assignments
  end
end
