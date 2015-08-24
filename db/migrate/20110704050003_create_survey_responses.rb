class CreateSurveyResponses < ActiveRecord::Migration
  def change
    create_table :survey_responses do |t|
      t.references :course, null: false, index: true
      t.references :user, null: false
      t.references :survey, null: false

      t.timestamps

      # Get a user's response to a survey.
      t.index [:user_id, :survey_id], unique: true
    end
  end
end
