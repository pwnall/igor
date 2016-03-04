class CreateProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, index: { unique: true }
      t.string :name, null: false, limit: 128
      t.string :nickname, null: false, limit: 64
      t.string :university, null: false, limit: 64
      t.string :department, null: false, limit: 64
      t.string :year, null: false, limit: 4

      t.timestamps null: false
    end
  end
end
