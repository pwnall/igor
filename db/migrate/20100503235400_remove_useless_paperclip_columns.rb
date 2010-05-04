class RemoveUselessPaperclipColumns < ActiveRecord::Migration
  def self.up
    remove_column :submissions, :code_medium_file
    remove_column :submissions, :code_thumb_file
    remove_column :deliverable_validations, :pkg_medium_file
    remove_column :deliverable_validations, :pkg_thumb_file
  end

  def self.down
    add_column :deliverable_validations, :pkg_thumb_file, :binary
    add_column :deliverable_validations, :pkg_medium_file, :binary
    add_column :submissions, :code_thumb_file, :binary
    add_column :submissions, :code_medium_file, :binary
  end
end
