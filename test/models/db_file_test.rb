require 'test_helper'

class DbFileTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.
  include FileGenerator

  before do
    attachment = fixture_file_upload 'analyzer_files/fib.zip',
        'application/zip', :binary
    @file = DbFile.new f: attachment
  end

  it 'validates the setup file' do
    assert @file.valid?
  end

  it 'saves the file contents to the database' do
    path = File.join ActiveSupport::TestCase.fixture_path, 'analyzer_files',
        'fib.zip'
    golden = File.binread path

    @file.save!

    # NOTE: This test doesn't pass before save! is called, because of Paperclip
    #       implementation details.
    assert_equal golden, @file.f.file_contents

    assert_equal golden, DbFile.find(@file.id).f.file_contents
  end

  it 'requires a file attachment' do
    @file.f = nil
    assert @file.invalid?
  end

  it 'rejects attachments 16 megabytes or larger' do
    @file.f = large_file
    assert @file.invalid?
  end

  it 'rejects html files' do
    @file.f = html_file
    assert_equal 'text/html', @file.f_content_type
    assert @file.invalid?
  end

  it 'rejects xhtml files' do
    @file.f = xhtml_file
    assert_equal 'application/xhtml+xml', @file.f_content_type
    assert @file.invalid?
  end
end
