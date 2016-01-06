class CreateSurveyAnswers < ActiveRecord::Migration
  def change
    create_table :survey_answers do |t|
      t.references :question, null: false
      t.references :response, null: false
      t.decimal :number, null: true, precision: 7, scale: 2
      t.string :comment, limit: 1.kilobyte, null: true

      t.timestamps null: false

      t.index [:response_id, :question_id], unique: true
    end
  end
end
