class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :exuid, limit: 32, null: false

      t.timestamps null: false

      t.index :exuid, unique: true
    end
  end
end
