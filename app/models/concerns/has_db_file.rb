require 'active_support'

# Database-backed file support.
#
# AssignmentFile, ScriptAnalyzer, and Submission currently use database files.
module HasDbFile
  extend ActiveSupport::Concern

  included do
    # The database-backed file holding the script, resource, or submission.
    belongs_to :db_file, dependent: :destroy
    validates :db_file, presence: true, uniqueness: true
    validates_associated :db_file
    accepts_nested_attributes_for :db_file, reject_if: :all_blank

    # Uploading a new script or assignment file should destroy the old file.
    #
    # NOTE: The db_file should never change for a submission.
    def destroy_former_db_file
      return unless db_file_id_changed?
      DbFile.find(db_file_id_was).destroy
    end
    after_update :destroy_former_db_file,
        unless: Proc.new { |record| record.instance_of? Submission }
    private :destroy_former_db_file
  end

  # The name of the uploaded file.
  def file_name
    db_file && db_file.f_file_name
  end

  # The contents of the uploaded file.
  def contents
    db_file && db_file.f.file_contents
  end
end
