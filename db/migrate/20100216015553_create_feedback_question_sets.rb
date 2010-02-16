class CreateFeedbackQuestionSets < ActiveRecord::Migration
  def self.up
    create_table :feedback_question_sets do |t|
      t.string :name, :limit => 128, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :feedback_question_sets
  end
end
