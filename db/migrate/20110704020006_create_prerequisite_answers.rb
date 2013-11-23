class CreatePrerequisiteAnswers < ActiveRecord::Migration
  def change
    create_table :prerequisite_answers do |t|
      t.references :registration, null: false
      t.references :prerequisite, null: false
      t.boolean :took_course, null: false
      t.text :waiver_answer, limit: 4.kilobytes

      t.timestamps
    end

    # Optimize getting prerequisite answers for a registration.
    add_index :prerequisite_answers, [:registration_id, :prerequisite_id],
              unique: true, name: 'prerequisites_for_a_registration'
  end
end
