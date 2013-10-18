class AddCommentsToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :comments, :text, :after => :score
  end
end
