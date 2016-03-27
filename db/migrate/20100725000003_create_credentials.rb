class CreateCredentials < ActiveRecord::Migration[5.0]
  def change
    create_table :credentials do |t|
      t.references :user, null: false, index: false, foreign_key: true
      t.string :type, limit: 32, null: false
      t.string :name, limit: 128, null: true

      t.timestamp :updated_at, null: false

      t.binary :key, limit: 2.kilobytes, null: true

      # All the credentials (maybe of a specific type) belonging to a user.
      t.index [:user_id, :type], unique: false
      # A specific credential, to find out what user it belongs to.
      t.index [:type, :name], unique: true
      # Expired credentials (particularly useful for tokens).
      t.index [:type, :updated_at], unique: false
    end
  end
end
