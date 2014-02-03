class CreateGradeComments < ActiveRecord::Migration
  def change
    create_table :grade_comments do |t|
      t.references :grade, null: false
      t.references :grader, null: false
      t.string :comment, limit: 4.kilobytes, null: false

      t.timestamps
    end

    # Ensure that each comment only has one grade associated.
    add_index :grade_comments, :grade_id, unique: true
  end
end
