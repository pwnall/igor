class CreateExamAttendances < ActiveRecord::Migration
  def change
    create_table :exam_attendances do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :exam, foreign_key: true, null: false
      t.references :exam_session, foreign_key: true, null: false
      t.boolean :confirmed, null: false

      t.timestamps null: false

      t.index [:exam_id, :user_id], unique: true
      t.index [:exam_session_id, :user_id], unique: true
    end
  end
end
