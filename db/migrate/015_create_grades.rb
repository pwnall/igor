class CreateGrades < ActiveRecord::Migration
  def self.up
    create_table :grades do |t|
      t.integer :assignment_metric_id
      t.integer :user_id
      t.integer :grader_user_id
      t.integer :score

      t.timestamps
    end
  end

  def self.down
    drop_table :grades
  end
end
