class CreatePrerequisites < ActiveRecord::Migration
  def change
    create_table :prerequisites do |t|
      t.references :course, null: false
      t.string :prerequisite_number, limit: 64, null: false
      t.string :waiver_question, limit: 256, null: false

      t.timestamps
    end
    
    add_index :prerequisites, [:course_id, :prerequisite_number],
                              null: false, unique: true
  end
end
