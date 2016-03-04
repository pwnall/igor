class CreateExams < ActiveRecord::Migration[4.2]
  def change
    create_table :exams do |t|
      t.references :assignment, index: { unique: true }, foreign_key: true,
          null: false
      t.boolean :requires_confirmation, null: false
    end
  end
end
