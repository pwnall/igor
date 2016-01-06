class CreateGradeComments < ActiveRecord::Migration
  def change
    create_table :grade_comments do |t|
      t.references :course, null: false
      t.references :metric, null: false
      t.references :grader, null: false
      t.references :subject, polymorphic: { limit: 16 }, null: false
      t.text :text, limit: 4.kilobytes, null: false

      t.timestamps null: false

      # Get comments for a user/team.
      t.index [:subject_id, :subject_type, :metric_id], unique: true,
          name: 'index_grade_comments_on_subject_and_metric_id'
      # Get a user's comments for a course.
      t.index [:subject_id, :subject_type, :course_id],
          name: 'index_grade_comments_on_subject_and_course_id'
    end
  end
end
