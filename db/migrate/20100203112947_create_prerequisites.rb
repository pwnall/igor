class CreatePrerequisites < ActiveRecord::Migration
  def self.up
    create_table :prerequisites do |t|
      t.string :course_number, :limit => 64, :null => false
      t.string :waiver_question, :limit => 256, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :prerequisites
  end
end
