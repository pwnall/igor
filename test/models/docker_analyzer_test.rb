require 'test_helper'

class DockerAnalyzerTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.

  before do
    deliverable = assignments(:ps1).deliverables.build name: 'Moar code',
        description: 'Waay more', file_ext: 'py'
    @analyzer = DockerAnalyzer.new deliverable: deliverable,
        auto_grading: false, db_file: db_files(:ps2_docker_analyzer),
        map_time_limit: 2, map_ram_limit: 1024, reduce_time_limit: 2,
        reduce_ram_limit: 1024
  end

  let(:analyzer) { analyzers(:docker_assessment_code) }

  it 'validates the setup analyzer' do
    assert @analyzer.valid?, @analyzer.errors.full_messages
  end

  describe 'core analyzer functionality' do
    it 'requires a deliverable' do
      @analyzer.deliverable = nil
      assert @analyzer.invalid?
    end

    it 'forbids a deliverable from having multiple analyzers' do
      @analyzer.deliverable = analyzer.deliverable
      assert @analyzer.invalid?
    end

    it 'must state whether grades are automatically updated' do
      @analyzer.auto_grading = nil
      assert @analyzer.invalid?
    end
  end

  describe 'HasDbFile concern' do
    it 'requires a database-backed file with the docker template zip' do
      @analyzer.db_file = nil
      assert @analyzer.invalid?
    end

    it 'destroys dependent records' do
      assert_not_nil analyzer.db_file

      analyzer.destroy

      assert_nil DbFile.find_by(id: analyzer.db_file_id)
    end

    it 'forbids multiple analyzers from using the same file in the database' do
      @analyzer.db_file = analyzer.db_file
      assert @analyzer.invalid?
    end

    it 'validates associated database-backed files' do
      db_file = @analyzer.build_db_file
      assert_equal false, db_file.valid?
      assert_equal false, @analyzer.valid?
    end

    it 'saves associated database-backed files through the parent analyzer' do
      assert_equal true, @analyzer.new_record?
      @analyzer.save!
      assert_not_nil @analyzer.reload.db_file
    end

    it 'rejects database file associations with a blank attachment' do
      assert_equal 'fib_small.zip', analyzer.db_file.f_file_name
      analyzer.update! db_file_attributes: { f: '' }
      assert_equal 'fib_small.zip', analyzer.reload.db_file.f_file_name
    end

    it 'destroys the database file when it is replaced' do
      assert_not_nil analyzer.db_file
      former_db_file_id = analyzer.db_file.id
      new_db_file = fixture_file_upload 'analyzer_files/fib.zip',
          'application/zip', :binary
      analyzer.update! db_file_attributes: { f: new_db_file }
      assert_nil DbFile.find_by(id: former_db_file_id)
    end

    describe '#file_name' do
      it 'returns the name of the uploaded file' do
        assert_equal 'fib_small.zip', analyzer.file_name
      end

      it 'returns nil if no file has been uploaded' do
        analyzer.db_file = nil
        assert_nil analyzer.file_name
      end
    end

    describe '#contents' do
      it 'returns the contents of the uploaded file' do
        path = File.join ActiveSupport::TestCase.fixture_path, 'analyzer_files',
            'fib_small.zip'
        assert_equal File.binread(path), analyzer.contents
      end

      it 'returns nil if no file has been uploaded' do
        analyzer.db_file = nil
        assert_nil analyzer.contents
      end
    end
  end
end
