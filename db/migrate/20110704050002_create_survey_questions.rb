class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.integer :scale_min, null: false, default: 1
      t.integer :scale_max, null: false, default: 5
      t.boolean :scaled, null: false, default: false
      t.boolean :targets_user, null: false, default: false
      t.boolean :allows_comments, null: false, default: false

      t.string :human_string, limit: 1.kilobyte, null: false
      t.string :scale_min_label, limit: 64, null: false, default: 'Small'
      t.string :scale_max_label, limit: 64, null: false, default: 'Large'

      t.timestamps
    end
  end
end
