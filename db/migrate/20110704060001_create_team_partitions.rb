class CreateTeamPartitions < ActiveRecord::Migration
  def change
    create_table :team_partitions do |t|
      t.references :course, null: false
      t.string :name, limit: 64, null: false
      t.integer :min_size, null: false
      t.integer :max_size, null: false

      t.boolean :automated, null: false, default: true
      t.boolean :editable, null: false, default: true
      t.boolean :released, null: false, default: false

      t.timestamps null: false

      t.index [:course_id, :name], unique: true
    end
  end
end
