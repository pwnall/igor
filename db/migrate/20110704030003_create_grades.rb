class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.references :course, null: false
      # Get grades for an assignment.
      t.references :metric, null: false, index: true
      t.references :grader, null: false
      t.references :subject, polymorphic: { limit: 64 }, null: false
      t.decimal :score, precision: 8, scale: 2, null: false

      t.timestamps

      # Get grades for a user/team.
      t.index [:subject_id, :subject_type, :metric_id], unique: true
      # Get a user's grades for a course.
      t.index [:subject_id, :subject_type, :course_id]
    end
  end
end
