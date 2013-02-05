class CreateRecitationPartition < ActiveRecord::Migration
  def change
    create_table :recitation_partitions do |t|
      t.references :course, null: false
      t.integer :section_size, null: false
      t.integer :section_count, null: false

      t.datetime :created_at
    end

    add_index :recitation_partitions, :course_id, null: false, unique: false
  end
end
