class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :grade, null: false
      t.references :grader, null: false
      t.string :comment, limit: 1024

      t.timestamps
    end

    # Ensure each comment only has one grade associated
    add_index :comments, :grade_id, unique: true
  end
end
