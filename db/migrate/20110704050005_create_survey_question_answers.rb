class CreateSurveyQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :survey_question_answers, force: true do |t|
      t.integer :survey_answer_id, null: false
      t.integer :question_id, null: false
      t.integer :target_user_id, null: true
      t.float :number, null: false, limit: 7, precision: 2
      t.string :comment, limit: 1.kilobyte, null: true

      t.timestamps
    end
    
    add_index :survey_question_answers,
              [:survey_answer_id, :question_id, :target_user_id],
              null: true, unique: true,
              name: 'survey_question_answers_by_answer_question_user'
  end
end
