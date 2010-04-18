class CreateAssignmentMetrics < ActiveRecord::Migration
  def self.up
    create_table :assignment_metrics do |t|
      t.string :name, :limit => 64, :null => false
      t.integer :assignment_id, :null => false
      t.integer :max_score, :null => true
      t.boolean :published, :nil => false, :default => false
      t.decimal :weight, :precision => 16, :scale => 8, :null => false, :default => 1.0

      t.timestamps
    end
  end

  def self.down
    drop_table :assignment_metrics
  end
end
