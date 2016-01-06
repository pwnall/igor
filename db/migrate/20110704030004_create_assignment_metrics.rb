class CreateAssignmentMetrics < ActiveRecord::Migration
  def change
    create_table :assignment_metrics do |t|
      t.references :assignment, null: false
      t.string :name, limit: 64, null: false
      t.integer :max_score, null: false
      t.decimal :weight, precision: 16, scale: 8, null: false

      t.timestamps null: false

      t.index [:assignment_id, :name], unique: true
    end
  end
end
