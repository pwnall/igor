class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :name, limit: 128, null: false
      t.boolean :released, null: false
      t.references :course, null: false

      t.timestamps null: false

      t.index [:course_id, :name], unique: true
    end
  end
end
