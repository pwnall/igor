# rake db:migrate:reset docker:bm JOBS=10
# `docker:bm` is equivalent to `docker:build_db docker:benchmark`

require 'benchmark'
include ActionDispatch::TestProcess  # Want fixture_file_upload.

# Helper functions for :docker_benchmark rake tasks.
module DockerBenchmark
  # Create a submission for the given deliverable and user.
  def self.create_submission(deliverable, user)
    Submission.create! deliverable: deliverable, uploader: user,
        upload_ip: '127.0.0.1', file: fixture_file_upload(
          'test/fixtures/files/submission/good_fib.py', 'text/x-python',
          :binary)
  end
end

namespace :docker do
  desc "Populate the database with minimal records for Docker benchmarking."
  task build_db: :environment do
    # Course.
    Course.destroy_all
    course = Course.new
    course.update! number: '1.337', title: 'Intro to Pwnage',
        email: "1.337-staff@mit.edu", ga_account: "docker_benchmark_test",
        email_on_role_requests: true, has_recitations: false,
        has_surveys: false, has_teams: false, section_size: 20
    puts 'Course created.'

    # Site admin.
    admin = User.create! email: 'admin@mit.edu', password: 'mit',
        password_confirmation: 'mit', profile_attributes: { name: 'Admin',
          nickname: 'admin', university: 'MIT', department: 'EECS', year: 'G'
        }
    admin.email_credential.verified = true
    admin.save!
    Role.create! user: admin, name: 'admin'
    puts 'Admin created.'

    # Staff.
    staff = User.create! email: 'staff@mit.edu',  password: 'mit',
        password_confirmation: 'mit', profile_attributes: { name: 'Staff',
          nickname: 'staff', university: 'MIT', department: 'EECS', year: 'G'
        }
    staff.email_credential.verified = true
    staff.email_credential.save!
    Role.create! user: staff, course: course, name: 'staff'
    puts 'Staff created.'

    # Pset.
    base_time = Time.current.beginning_of_minute
    pset = Assignment.new name: "Problem Set 1", weight: 1.0, author: staff,
        course: course, grades_released: false, scheduled: true
    pset.build_deadline due_at: (base_time + 1.day), course: course
    pset.released_at = pset.due_at - 1.week
    pset.save!
    puts 'Pset created.'

    # Deliverable.
    docker_analyzer_file = 'test/fixtures/files/analyzer/fib_bench.zip'
    docker_analyzer_params = { type: 'DockerAnalyzer', map_time_limit: '2',
      map_ram_limit: '1024', map_logs_limit: '1', reduce_time_limit: '2',
      reduce_ram_limit: '1024', reduce_logs_limit: '10',
      auto_grading: false, file:
        fixture_file_upload(docker_analyzer_file, 'application/zip', :binary)
        }
    deliverable = pset.deliverables.create! name: 'Fibonacci',
        description: 'Please upload your modified fib.py.',
        analyzer_attributes: docker_analyzer_params
    puts 'Deliverable created.'
  end

  desc "Benchmark the time for creating/destroying JOBS x 10 Docker containers."
  task benchmark: :environment do |t, args|
    deliverable = Deliverable.first
    user = User.includes(:roles).find_by roles: { name: 'staff' }
    unless deliverable && user
      raise 'Missing database records. Run `rake benchmark_docker:build_db.`'
    end

    # Download whichever Docker image is required in the analyzer's Dockerfile
    # during a 'dummy' analysis whose runtime is not included in the final
    # benchmark.
    submission = DockerBenchmark.create_submission deliverable, user
    SubmissionAnalysisJob.perform_now submission

    submissions = []
    job_count = ENV['JOBS'].to_i
    job_count.times do
      submissions << DockerBenchmark.create_submission(deliverable, user)
    end

    Benchmark.bm(10) do |b|
      b.report("#{job_count} jobs:") do
        submissions.each { |s| SubmissionAnalysisJob.perform_now s }
      end
    end
  end

  desc 'Build minimal db and benchmark setup for JOBS x 10 Docker containers.'
  task bm: [:build_db, :benchmark]
end
