class CreateDeliverables < ActiveRecord::Migration
  def self.up
    create_table :deliverables do |t|
      # the assignment that this deliverable belongs to
      t.integer :assignment_id, :null => false
      
      # the deliverable name (e.g. Writeup, Problem 3 Code)
      t.string :name, :limit => 80, :null => false
      # short description
      t.string :description, :limit => 2.kilobytes, :null => false
      
      # indicates if the deliverable has been published
      t.boolean :published, :null => false, :default => false
      
      # the standard filename of the deliverable (e.g. writeup.pdf, trees.py)
      t.string :filename, :limit => 256, :null => false, :default => ''

      # we keep these around for auditing purposes
      t.timestamps
    end
    
    add_index :deliverables, :assignment_id, :unique => false
  end

  def self.down
    drop_table :deliverables
  end
end
