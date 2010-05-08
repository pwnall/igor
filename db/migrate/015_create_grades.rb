class CreateGrades < ActiveRecord::Migration
  def self.up
    create_table :grades do |t|
      t.integer :metric_id, :null => false
      t.string  :subject_type, :limit => 64, :null => false
      t.integer :subject_id, :null => false
      t.integer :grader_id, :null => false
      t.decimal :score, :precision => 8, :scale => 2, :null => false

      t.timestamps
    end
    
    # Optimize getting the grades for a user / team.
    add_index :grades, [:subject_type, :subject_id, :metric_id],
                       :unique => true, :null => false,
                       :name => 'grades_by_subject_and_metric_id'
  end

  def self.down
    drop_table :grades
  end
end
