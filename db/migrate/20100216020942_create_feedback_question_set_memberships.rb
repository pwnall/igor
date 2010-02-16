class CreateFeedbackQuestionSetMemberships < ActiveRecord::Migration
  def self.up
    create_table :feedback_question_set_memberships do |t|
      t.integer :feedback_question_id, :null => false
      t.integer :feedback_question_set_id, :null => false
      
      t.datetime :created_at
    end
    add_index :feedback_question_set_memberships,
              [:feedback_question_id, :feedback_question_set_id],
              :null => false, :unique => true,
              :name => 'feedback_question_set_to_questions'
    add_index :feedback_question_set_memberships,
              [:feedback_question_set_id, :feedback_question_id],
              :null => false, :unique => true,
              :name => 'feedback_questions_to_sets'
  end

  def self.down
    drop_table :feedback_question_set_memberships
  end
end
