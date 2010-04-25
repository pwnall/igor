class RenameAssignmentMetricId < ActiveRecord::Migration
  def self.up
    rename_column :grades, :assignment_metric_id, :metric_id 
  end

  def self.down
    rename_column :grades, :metric_id, :assignment_metric_id 
  end
end
