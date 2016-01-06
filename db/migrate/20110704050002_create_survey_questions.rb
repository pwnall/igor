class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.references :survey, null: false
      t.string :prompt, limit: 1.kilobyte, null: false
      t.boolean :allows_comments, null: false
      t.string :type, limit: 32, null: false
      t.text :features, null: false

      t.timestamps null: false
    end
  end
end
