class CreateFeedbackAnswers < ActiveRecord::Migration
  def self.up
    create_table :feedback_answers, :force => true do |t|
      t.integer :assignment_feedback_id, :null => false
      t.integer :question_id, :null => false
      t.integer :target_user_id, :null => true
      t.float :number, :null => false, :limit => 7, :precision => 2
      t.string :comment, :limit => 1.kilobyte, :null => true

      t.timestamps
    end
    add_index :feedback_answers,
              [:assignment_feedback_id, :question_id, :target_user_id],
              :null => true, :unique => true,
              :name => 'feedback_answers_by_assignment_question_user'
  end

  def self.down
    drop_table :feedback_answers
  end
end