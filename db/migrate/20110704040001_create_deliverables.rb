class CreateDeliverables < ActiveRecord::Migration
  def change
    create_table :deliverables do |t|
      t.references :assignment, :null => false
      t.string :name, :limit => 80, :null => false
      t.string :description, :limit => 2.kilobytes, :null => false
      
      t.timestamps
    end
    
    add_index :deliverables, [:assignment_id, :name], :null => false,
                                                      :unique => true
  end
end
