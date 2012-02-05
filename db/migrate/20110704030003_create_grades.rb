class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.references :metric, :null => false
      t.references :grader, :null => false
      t.references :subject, :polymorphic => true, :null => false
      t.decimal :score, :precision => 8, :scale => 2, :null => false

      t.timestamps
    end
    
    # Optimize getting the grades for a user / team.
    add_index :grades, [:subject_id, :subject_type, :metric_id],
                       :unique => true, :null => false,
                       :name => 'grades_by_subject_and_metric'
  end
end
