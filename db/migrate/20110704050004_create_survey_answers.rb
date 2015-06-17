class CreateSurveyAnswers < ActiveRecord::Migration
  def change
    create_table :survey_answers do |t|
      t.references :user, index: true, null: false
      t.references :survey, index: true, null: false

      t.index [:user_id, :survey_id], unique: true
      
      t.timestamps
    end
  end
end
