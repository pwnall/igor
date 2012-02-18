class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.references :course, null: false
      t.references :author, null: false
      
      t.references :team_partition, null: true
      t.references :feedback_survey, null: true

      t.datetime :deadline, null: false
      t.decimal :weight, precision: 16, scale: 8, null: false, default: 1.0

      t.string :name, limit: 64, null: false
      
      t.boolean :deliverables_ready, null: false, default: false
      t.boolean :metrics_ready, null: false, default: false
      t.boolean :accepts_feedback, null: false, default: false

      t.timestamps
    end
    
    add_index :assignments, [:course_id, :name], null: false, unique: true
    add_index :assignments, [:course_id, :deadline, :name], null: false,
                                                            unique: true
  end
end
