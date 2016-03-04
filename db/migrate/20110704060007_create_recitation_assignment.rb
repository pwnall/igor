class CreateRecitationAssignment < ActiveRecord::Migration[4.2]
  def change
    create_table :recitation_assignments do |t|
      t.references :recitation_partition, null: false
      t.references :user, null: false
      t.references :recitation_section, null: false

      t.index [:recitation_partition_id, :user_id], unique: true,
          name: 'recitation_assignments_to_partitions'
      t.index [:recitation_partition_id, :recitation_section_id], unique: false,
          name: 'recitation_assignments_to_sections'
    end
  end
end
