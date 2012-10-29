class AddRecitationSizeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :recitation_size, :integer
  end
end
