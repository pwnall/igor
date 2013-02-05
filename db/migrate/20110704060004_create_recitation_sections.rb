class CreateRecitationSections < ActiveRecord::Migration
  def change
    create_table :recitation_sections do |t|
      t.references :course, null: false
      t.references :leader, null: false
      t.integer :serial, null: false
      t.string :time, limit: 64, null: false
      t.string :location, limit: 64, null: false

      t.timestamps
    end

    add_index :recitation_sections, [:course_id, :serial],
                                    unique: true, null: false
  end
end
