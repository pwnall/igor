class CreateSurveyQuestionMemberships < ActiveRecord::Migration
  def self.up
    create_table :survey_question_memberships do |t|
      t.integer :survey_question_id, :null => false
      t.integer :survey_id, :null => false
      
      t.datetime :created_at
    end
    add_index :survey_question_memberships, [:survey_question_id, :survey_id],
              :null => false, :unique => true,
              :name => 'surveys_to_survey_questions'
    add_index :survey_question_memberships, [:survey_id, :survey_question_id],
              :null => false, :unique => true,
              :name => 'survey_questions_to_surveys'
  end

  def self.down
    drop_table :survey_question_memberships
  end
end
