class CreateRecitationConflicts < ActiveRecord::Migration
  def self.up
    create_table :recitation_conflicts do |t|
      # the student info object this is tied to
      t.integer :student_info_id, :null => false
      # the MIT name of the class causing the conflict (e.g. 6.001)
      t.string :class_name, :null => false
      # the time slot when the conflict occurs (xxy base 10, where xx = hour 10..16, y=0/wed,1/fri) 
      t.integer :timeslot, :null => false
    end
    add_index :recitation_conflicts, [:student_info_id, :timeslot], :unique => true
  end

  def self.down
    remove_index :recitation_conflicts, [:student_info_id, :timeslot]
    drop_table :recitation_conflicts
  end
end
