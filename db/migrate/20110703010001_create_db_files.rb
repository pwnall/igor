class CreateDbFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :db_files do |t|
      t.datetime :created_at, null: false
    end

    add_attachment :db_files, :f
  end
end
