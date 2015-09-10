class CreateEmailResolvers < ActiveRecord::Migration
  def change
    create_table :email_resolvers do |t|
      t.string :domain, limit: 128, null: false, index: { unique: true }
      t.text :ldap_server, limit: 256, null: false
      t.text :ldap_auth_dn, limit: 256, null: true
      t.text :ldap_password, limit: 256, null: false
      t.text :ldap_search_base, limit: 256, null: false
      t.text :name_ldap_key, limit: 64, null: false
      t.text :dept_ldap_key, limit: 64, null: false
      t.text :year_ldap_key, limit: 64, null: false
      t.text :user_ldap_key, limit: 64, null: false
      t.boolean :use_ldaps, null: false
    end
  end
end
