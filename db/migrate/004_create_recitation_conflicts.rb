class CreateRecitationConflicts < ActiveRecord::Migration
  def self.up
    create_table :recitation_conflicts do |t|
      t.integer :registration_id, :null => false
      t.integer :timeslot, :null => false
      t.string :class_name, :null => false
    end
    add_index :recitation_conflicts, [:registration_id, :timeslot],
                                     :unique => true, :null => false
  end

  def self.down
    drop_table :recitation_conflicts
  end
end
