class CreateDeliverables < ActiveRecord::Migration
  def self.up
    create_table :deliverables do |t|
      t.integer :assignment_id, :null => false
      t.string :name, :limit => 80, :null => false
      t.string :description, :limit => 2.kilobytes, :null => false
      t.boolean :published, :null => false, :default => false
      t.string :filename, :limit => 256, :null => false, :default => ''
      
      t.timestamps
    end
    
    add_index :deliverables, [:assignment_id, :name], :null => false,
                                                      :unique => true
  end

  def self.down
    drop_table :deliverables
  end
end
