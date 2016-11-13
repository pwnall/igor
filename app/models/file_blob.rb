# == Schema Information
#
# Table name: file_blobs
#
#  id   :string(48)       not null, primary key
#  data :binary           not null
#

# Stores the contents of database-backed files for this application.
class FileBlob < ActiveRecord::Base
  include FileBlobs::BlobModel

  # The list below must include all the models that that use has_file_blob and
  # store data using this model class. Omitting a module will lead to data
  # loss, as content blobs will get garbage-collected prematurely.
  blob_owner_class_names! 'AssignmentFile', 'DockerAnalyzer', 'ProfilePhoto',
                          'Submission'

  # Place any extensions to the file contents blob class below.
end
