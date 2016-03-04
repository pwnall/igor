class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :exuid, limit: 32, null: false

      t.timestamps null: false
    end

    add_index :users, :exuid, unique: true
  end
end
