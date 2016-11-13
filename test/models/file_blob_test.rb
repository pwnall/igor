require 'test_helper'

class FileBlobTest < ActiveSupport::TestCase
  test 'blob_owner_classes all use has_file_blob' do
    FileBlob.blob_owner_classes.each do |klass|
      assert klass.respond_to?(:file_blob_eligible_for_garbage_collection?), klass.name
    end
  end
end
