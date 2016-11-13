require 'test_helper'

class DockerAnalyzerTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.

  before do
    ContainedMr.stubs(:template_class).returns ContainedMr::Mock::Template

    deliverable = assignments(:ps1).deliverables.build name: 'Moar code',
        description: 'Waay more'
    @analyzer = DockerAnalyzer.new deliverable: deliverable,
        auto_grading: false, map_time_limit: '1.5', map_ram_limit: '128',
        map_logs_limit: '1.5', reduce_time_limit: '2.9',
        reduce_ram_limit: '1024', reduce_logs_limit: '10',
        file: fixture_file_upload('files/analyzer/fib_small.zip',
                                  'application/zip', :binary)
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

  describe 'has_file_blob directive' do
    it 'is wired correctly' do
      assert_equal 'application/zip', @analyzer.file.mime_type
      assert_equal 'fib_small.zip', @analyzer.file.original_name
      assert_equal file_blob_id('files/analyzer/fib_small.zip'),
          @analyzer.file.blob.id
      assert_equal file_blob_size('files/analyzer/fib_small.zip'),
          @analyzer.file.size
      assert_equal file_blob_data('files/analyzer/fib_small.zip'),
          @analyzer.file.data
    end

    it 'has allow_nil set to false' do
      @analyzer.file = nil
      assert @analyzer.invalid?
    end
  end

  describe 'DockerAnalyzer-specific attributes' do
    it 'validates fixture analyzers (validate JSON serialization)' do
      assert analyzer.valid?
    end

    it 'requires a :map_time_limit' do
      @analyzer.map_time_limit = nil
      assert @analyzer.invalid?
    end

    it 'rejects non-positive values for :map_time_limit' do
      @analyzer.map_time_limit = 0
      assert @analyzer.invalid?
    end

    it 'requires a :map_ram_limit' do
      @analyzer.map_ram_limit = nil
      assert @analyzer.invalid?
    end

    it 'rejects non-integer values for :map_ram_limit' do
      @analyzer.map_ram_limit = 1.5
      assert_equal 1, @analyzer.map_ram_limit
    end

    it 'rejects non-positive values for :map_ram_limit' do
      @analyzer.map_ram_limit = 0
      assert @analyzer.invalid?
    end

    it 'requires a :map_logs_limit' do
      @analyzer.map_logs_limit = nil
      assert @analyzer.invalid?
    end

    it 'rejects non-positive values for :map_logs_limit' do
      @analyzer.map_logs_limit = 0
      assert @analyzer.invalid?
    end

    it 'requires a :reduce_time_limit' do
      @analyzer.reduce_time_limit = nil
      assert @analyzer.invalid?
    end

    it 'rejects non-positive values for :reduce_time_limit' do
      @analyzer.reduce_time_limit = 0
      assert @analyzer.invalid?
    end

    it 'requires a :reduce_ram_limit' do
      @analyzer.reduce_ram_limit = nil
      assert @analyzer.invalid?
    end

    it 'rejects non-integer values for :reduce_ram_limit' do
      @analyzer.reduce_ram_limit = 1.5
      assert_equal 1, @analyzer.reduce_ram_limit
    end

    it 'rejects non-positive values for :reduce_ram_limit' do
      @analyzer.reduce_ram_limit = 0
      assert @analyzer.invalid?
    end

    it 'requires a :reduce_logs_limit' do
      @analyzer.reduce_logs_limit = nil
      assert @analyzer.invalid?
    end

    it 'rejects non-positive values for :reduce_logs_limit' do
      @analyzer.reduce_logs_limit = 0
      assert @analyzer.invalid?
    end
  end

  describe '#run_submission' do
    it 'sets job time limits correctly' do
      job = @analyzer.run_submission submissions(:dexter_code)
      assert_equal 1.5, job.mapper_runner(1)._time_limit
      assert_equal 2.9, job.reducer_runner._time_limit
    end

    it 'sets job ulimits correctly' do
      job = @analyzer.run_submission submissions(:dexter_code)

      assert_equal 2, job.mapper_runner(1)._ulimit('cpu')
      assert_equal 128, job.mapper_runner(1)._ram_limit
      assert_equal 0, job.mapper_runner(1)._swap_limit
      assert_equal 1, job.mapper_runner(1)._vcpus
      assert_equal 1.5, job.mapper_runner(1)._logs
      assert_equal 3, job.reducer_runner._ulimit('cpu')
      assert_equal 1024, job.reducer_runner._ram_limit
      assert_equal 0, job.reducer_runner._swap_limit
      assert_equal 1, job.reducer_runner._vcpus
      assert_equal 10, job.reducer_runner._logs
    end

    it 'provides the correct job input' do
      job = @analyzer.run_submission submissions(:dexter_code)
      good_fib_path = File.join(
          ActiveSupport::TestCase.fixture_path, 'files/submission/good_fib.py')
      good_fib = File.read good_fib_path

      assert_equal good_fib, job._mapper_input
    end
  end
end
