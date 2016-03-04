class CreateSmtpServers < ActiveRecord::Migration[4.2]
  def change
    create_table :smtp_servers do |t|
      t.string :host, null: false, limit: 128
      t.integer :port, null: false
      t.string :domain, null: false, limit: 128
      t.string :user_name, null: false, limit: 128
      t.string :password, null: false, limit: 128
      t.string :from, null: false, limit: 128
      t.string :auth_kind, null: true
      t.boolean :auto_starttls, null: false
    end
  end
end
