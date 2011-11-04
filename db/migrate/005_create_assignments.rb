class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :course_id, :null => false
      t.datetime :deadline, :null => false
      t.decimal :weight, :null => true, :precision => 9, :scale => 6
      t.string :name, :limit => 64, :null => false
      
      t.integer :team_partition_id, :null => true
      t.integer :feedback_survey_id, :null => true
      t.boolean :accepts_feedback, :null => false, :default => false

      t.timestamps
    end
    
    add_index :assignments, [:course_id, :name], :null => false, :unique => true
    add_index :assignments, [:course_id, :deadline, :name], :null => false,
                                                            :unique => true
  end
end
