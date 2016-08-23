# Patch for Paperclip's lib/paperclip/io_adapters/uploaded_file_adapter.rb
#
# This is needed because of https://github.com/thoughtbot/paperclip/pull/2270
module Paperclip
  class UploadedFileAdapter
    def content_type_detector
      nil
    end
  end
end
