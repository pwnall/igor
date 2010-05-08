class CreatePrerequisiteAnswers < ActiveRecord::Migration
  def self.up
    create_table :prerequisite_answers do |t|
      t.integer :registration, :null => false
      t.integer :prerequisite_id, :null => false
      t.boolean :took_course, :null => false
      t.text :waiver_answer, :limit => 4.kilobytes

      t.timestamps
    end
    # Optimize getting prerequisite answers for a registration.
    add_index :prerequisite_answers, [:registration, :prerequisite_id],
              :unique => true, :null => false,
              :name => 'prerequisites_for_a_registration'
  end

  def self.down
    drop_table :prerequisite_answers
  end
end
