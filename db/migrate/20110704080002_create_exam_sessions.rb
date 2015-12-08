class CreateExamSessions < ActiveRecord::Migration
  def change
    create_table :exam_sessions do |t|
      t.references :course, foreign_key: true, null: false
      t.references :exam, foreign_key: true, null: false
      t.string :name, limit: 64, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :capacity, null: false

      t.index [:exam_id, :name], unique: true
      t.index [:course_id, :starts_at]
    end
  end
end
