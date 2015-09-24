require 'test_helper'

class AssignmentFileTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess  # For fixture_file_upload.

  before do
    @resource = AssignmentFile.new description: 'PS1 Test Cases',
        assignment: assignments(:ps1), db_file: db_files(:ps1_test_cases),
        published_at: 1.week.ago
  end

  let(:resource) { assignment_files(:ps1_solutions) }

  it 'validates the setup resource' do
    assert @resource.valid?
  end

  it 'requires a description' do
    @resource.description = nil
    assert @resource.invalid?
  end

  it 'rejects lengthy descriptions' do
    @resource.description = 'r' * 65
    assert @resource.invalid?
  end

  it 'requires a release time' do
    @resource.published_at = nil
    assert @resource.invalid?
  end

  describe '#can_read?' do
    let(:any_user) { User.new }

    describe 'passed the release time' do
      before { resource.update! published_at: 1.week.ago }

      describe 'the assignment has been released' do
        it 'lets any user view the file' do
          assert_equal true, resource.assignment.can_read?(any_user)
          assert_equal true, resource.can_read?(any_user)
          assert_equal true, resource.can_read?(nil)
        end
      end

      describe 'the assignment has not been released yet' do
        before { resource.update! assignment: assignments(:ps2) }

        it 'lets only course/site admins view the file' do
          assert_equal false, resource.assignment.can_read?(any_user)
          assert_equal false, resource.can_read?(any_user)
          assert_equal true, resource.can_read?(users(:main_staff))
          assert_equal true, resource.can_read?(users(:admin))
        end
      end
    end

    describe 'release time not yet passed' do
      before { resource.update! published_at: 1.week.from_now }

      it 'lets only course/site admins view the file' do
        assert_equal false, resource.can_read?(any_user)
        assert_equal true, resource.can_read?(users(:main_staff))
        assert_equal true, resource.can_read?(users(:admin))
      end
    end
  end

  describe 'HasDbFile concern' do
    it 'requires a database-backed file with the resource script' do
      @resource.db_file = nil
      assert @resource.invalid?
    end

    it 'destroys dependent records' do
      assert_not_nil resource.db_file

      resource.destroy

      assert_nil DbFile.find_by(id: resource.db_file_id)
    end

    it 'forbids multiple resources from using the same file in the database' do
      @resource.db_file = resource.db_file
      assert @resource.invalid?
    end

    it 'validates associated database-backed files' do
      db_file = @resource.build_db_file
      assert_equal false, db_file.valid?
      assert_equal false, @resource.valid?
    end

    it 'saves associated database-backed files through the parent resource' do
      assert_equal true, @resource.new_record?
      @resource.save!
      assert_not_nil @resource.reload.db_file
    end

    it 'rejects database file associations with a blank attachment' do
      assert_equal 'ps1_solutions.pdf', resource.db_file.f_file_name
      resource.update! db_file_attributes: { f: '' }
      assert_equal 'ps1_solutions.pdf', resource.reload.db_file.f_file_name
    end

    it 'destroys the database file when it is replaced' do
      assert_not_nil resource.db_file
      former_db_file_id = resource.db_file.id
      new_db_file = fixture_file_upload 'files/analyzer/fib.zip',
          'application/zip', :binary
      resource.update! db_file_attributes: { f: new_db_file }
      assert_nil DbFile.find_by(id: former_db_file_id)
    end

    describe '#file_name' do
      it 'returns the name of the uploaded file' do
        assert_equal 'ps1_solutions.pdf', resource.file_name
      end

      it 'returns nil if no file has been uploaded' do
        resource.db_file = nil
        assert_nil resource.file_name
      end
    end

    describe '#contents' do
      it 'returns the contents of the uploaded file' do
        path = File.join ActiveSupport::TestCase.fixture_path,
            'files/submission', 'small.pdf'
        assert_equal File.binread(path), resource.contents
      end

      it 'returns nil if no file has been uploaded' do
        resource.db_file = nil
        assert_nil resource.contents
      end
    end
  end
end
