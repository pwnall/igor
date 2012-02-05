class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.references :user, :null => false
      t.references :course, :null => false
      t.boolean :dropped, :null => false, :default => false
      t.boolean :teacher, :null => false, :default => false

      t.boolean :for_credit, :null => false, :default => true
      t.boolean :allows_publishing, :null => false, :default => true

      # TODO: move this to some partition class.
      t.references :recitation_section, :null => true

      t.timestamps
    end
    
    add_index :registrations, [:user_id, :course_id], :unique => true,
                                                      :null => false
    add_index :registrations, [:course_id, :user_id], :unique => true,
                                                      :null => false
  end
end
