class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :grade
      t.integer :grade_id
      t.text :comment

      t.timestamps
    end
    add_index :comments, :grade_id, unique: true
  end
end
