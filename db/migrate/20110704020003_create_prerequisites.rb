class CreatePrerequisites < ActiveRecord::Migration[4.2]
  def change
    create_table :prerequisites do |t|
      t.references :course, null: false
      t.string :prerequisite_number, limit: 64, null: false
      t.string :waiver_question, limit: 256, null: false

      t.timestamps null: false
    end

    add_index :prerequisites, [:course_id, :prerequisite_number], unique: true
  end
end
