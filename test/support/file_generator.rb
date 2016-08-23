module FileGenerator
  include ActionDispatch::TestProcess  # For fixture_file_upload.

  # Create a 128MB text file, if it doesn't exist.
  #
  # @return [Rack::Test::UploadedFile] a 16MB file in
  #   'test/fixtures/test_files/large_file.txt'
  def large_file
    new_or_existing_file 'large_file.txt', 'text/plain', 128.megabytes
  end

  # Create a 1MB HTML file, if it doesn't exist.
  #
  # @return [Rack::Test::UploadedFile] a 1MB file in
  #   'test/fixtures/test_files/hello.html'
  def html_file
    new_or_existing_file 'hello.html', 'text/html', 1.megabyte
  end

  # Create a 1MB XHTML file, if it doesn't exist.
  #
  # @return [Rack::Test::UploadedFile] a 1MB file in
  #   'test/fixtures/test_files/hello.xhtml'
  def xhtml_file
    new_or_existing_file 'hello.xhtml', 'application/xhtml+xml', 1.megabyte
  end

  # Create a file with the given name, MIME type, and size, if it doesn't exist.
  #
  # The generated file is saved to 'test/fixtures/test_files/'.
  #
  # @param [String] name the file name
  # @param [String] mime_type the MIME type of the file
  # @param [Integer] size the file size, in bytes
  # @return [Rack::Test::UploadedFile] the desired file
  def new_or_existing_file(name, mime_type, size)
    path = File.join ActiveSupport::TestCase.fixture_path, 'test_files', name
    unless File.exist?(path) && (File.size?(path) == size)
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w+') { |f| f.write '0' * size }
    end

    fixture_file_upload File.join('test_files', name), mime_type, :binary
  end
end
