class CreateAssignmentMetrics < ActiveRecord::Migration
  def self.up
    create_table :assignment_metrics do |t|
      # the name of the measurable metric (e.g. Problem 1) 
      t.string :name, :limit => 64, :null => false
      # the assignment that the metric belongs to
      t.integer :assignment_id, :null => false
      # the maximum score on the metric (for display purposes only; not enforced)
      t.integer :max_score, :null => true
      # indicates if non-admin users can see their scores on this metric
      t.boolean :published, :nil => false, :default => false
      # the weight of this metric in the overall class score (e.g. higher for exams than for psets)
      t.decimal :weight, :precision => 16, :scale => 8, :null => false, :default => 1.0

      # auditing
      t.timestamps
    end
  end

  def self.down
    drop_table :assignment_metrics
  end
end
