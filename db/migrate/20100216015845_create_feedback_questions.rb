class CreateFeedbackQuestions < ActiveRecord::Migration
  def self.up
    create_table :feedback_questions do |t|
      t.string :human_string, :limit => 1.kilobyte, :null => false
      t.boolean :targets_user, :null => false, :default => false
      t.boolean :scaled, :null => false, :default => false
      t.integer :scale_min, :null => false, :default => 1
      t.integer :scale_max, :null => false, :default => 5
      t.string :scale_min_label, :limit => 64, :null => false,
                                 :default => 'Small'
      t.string :scale_max_label, :limit => 64, :null => false,
                                 :default => 'Large'

      t.timestamps
    end
  end

  def self.down
    drop_table :feedback_questions
  end
end
