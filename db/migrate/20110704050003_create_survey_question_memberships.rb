class CreateSurveyQuestionMemberships < ActiveRecord::Migration
  def change
    create_table :survey_question_memberships do |t|
      t.references :survey_question, null: false
      t.references :survey, null: false

      t.datetime :created_at
    end

    add_index :survey_question_memberships, [:survey_question_id, :survey_id],
              unique: true, name: 'surveys_to_survey_questions'
    add_index :survey_question_memberships, [:survey_id, :survey_question_id],
              unique: true, name: 'survey_questions_to_surveys'
  end
end
