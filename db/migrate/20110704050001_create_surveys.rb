class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :name, limit: 128, null: false
      t.boolean :published, null: false

      t.timestamps
    end
  end
end
