class CreateDeadlines < ActiveRecord::Migration
  def change
    create_table :deadlines do |t|
      t.references :subject, polymorphic: true, index: true, unique: true,
          null: false
      t.datetime :due_at, null: false
      t.references :course, null: false

      t.index [:course_id, :subject_id, :subject_type], unique: true
    end
  end
end
