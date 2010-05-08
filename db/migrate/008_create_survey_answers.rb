class CreateSurveyAnswers < ActiveRecord::Migration
  def self.up
    create_table :survey_answers do |t|
      t.integer :user_id, :null => false
      t.integer :assignment_id, :null => false
      
      t.timestamps
    end
    add_index :survey_answers, [:user_id, :assignment_id], :unique => true
    add_index :survey_answers, :assignment_id
  end

  def self.down
    drop_table :survey_answers
  end
end
