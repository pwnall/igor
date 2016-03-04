class CreateRecitationPartition < ActiveRecord::Migration[4.2]
  def change
    create_table :recitation_partitions do |t|
      t.references :course, null: false, index: { unique: false }
      t.integer :section_size, null: false
      t.integer :section_count, null: false

      t.datetime :created_at
    end
  end
end
