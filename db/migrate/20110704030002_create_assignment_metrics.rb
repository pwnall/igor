class CreateAssignmentMetrics < ActiveRecord::Migration
  def change
    create_table :assignment_metrics do |t|
      t.references :assignment, null: false
      t.string :name, limit: 64, null: false
      t.integer :max_score, null: true

      t.timestamps
    end
    add_index :assignment_metrics, [:assignment_id, :name], unique: true
  end
end
