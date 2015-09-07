# == Schema Information
#
# Table name: analyzers
#
#  id             :integer          not null, primary key
#  deliverable_id :integer          not null
#  type           :string(32)       not null
#  auto_grading   :boolean          not null
#  exec_limits    :text
#  db_file_id     :integer
#  message_name   :string(64)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class DockerAnalyzer < Analyzer
  include HasDbFile

  # Limits for the student programs and for the analyzer script.
  store :exec_limits, coder: JSON

  # Maximum number of seconds of CPU time that the student's code can use.
  validates :map_time_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :map_time_limit

  # Maximum number of megabytes of RAM that the student's code can use.
  validates :map_ram_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :map_ram_limit

  # Maximum number of seconds of CPU time that the grading code can use.
  validates :reduce_time_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :reduce_time_limit

  # Maximum number of megabytes of RAM that the grading code can use.
  validates :reduce_ram_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :reduce_ram_limit

  # :nodoc: overrides Analyzer#analyze
  def analyze(submission)
    analysis = submission.analysis

    mr_job = run_submission submission
    analysis.status = extract_status mr_job
    json_grades = extract_grades mr_job
    if auto_grading?
      update_grades submission, json_grades
    end
    analysis.log = mr_job.reducer_runner.stdout || ''
    analysis.private_log = mr_job.reducer_runner.stderr || ''
    analysis.save!
  end

  # Runs the submission as a Map-Reduce job.
  #
  # @return {ContainedMr::Job} the job that ran
  def run_submission(submission)
    job_id = submission.db_file.id
    template_io = StringIO.new db_file.f.file_contents
    submission_string = submission.db_file.f.file_contents
    job_options = {
      mapper: { ulimits: { cpu: map_time_limit, rss: map_ram_limit * 256 } },
      reducer: { ulimits: { cpu: reduce_time_limit,
                            rss: reduce_ram_limit * 256 } },
    }

    # NOTE: We release the ActiveRecord connection because we won't use it for
    #       a while. All AR queries in this method should be done above this
    #       comment.
    ActiveRecord::Base.clear_active_connections!

    template = ContainedMr::Template.new 'alg_mr', job_id, template_io
    job = ContainedMr::Job.new template, job_id, job_options

    job.build_mapper_image submission_string
    1.upto job.item_count do |i|
      job.run_mapper i
    end
    job.build_reducer_image
    job.run_reducer
    job.destroy!
    template.destroy!

    return job
  end

  # Extracts the grades produced by a Map-Reduce job.
  #
  # @
  # @return {Hash<String, Number>} JSON grades output by the
  def extract_grades(mr_job)
    json_output = mr_job.reducer_runner && mr_job.reducer_runner.output
    return {} unless json_output
    begin
      JSON.parse json_output  # .split("\n", 2).first
    rescue JSON::JSONError
      return {}
    end
  end

  # Computes the analysis outcome based on a script's run result.
  def extract_status(mr_job)
    crashed = timed_out = false
    1.upto mr_job.item_count do |i|
      mapper = mr_job.mapper_runner i
      timed_out = true if mapper.timed_out
      crashed = true if !mapper.timed_out && mapper.status_code != 0
    end

    if crashed
      :crashed
    elsif timed_out
      :timed_out
    else
      :ok
    end
  end

  # Updates the database with the grades issued by the script.
  #
  # @return {Boolean} true if the database is updated; false if validation
  #   error occurred and grades were not changed
  def update_grades(submission, json_grades)
    assignment = submission.assignment
    grades = []
    json_grades.each do |metric_name, score_fraction|
      metric = assignment.metrics.where(name: metric_name).first
      unless metric
        #run_state[:private_log] << "Metric not found: #{metric_name}\n"
        next
      end
      grade = metric.grade_for submission.subject
      grade.score = score_fraction * metric.max_score
      grade.grader = User.robot
      unless grade.valid?
        #run_state[:private_log] <<
        #    "Produced invalid grade for metric #{metric_name}\n"
        #run_state[:private_log] << grade.errors.messages.inspect + "\n"
        return false
      end
      grades << grade
    end
    grades.each(&:save!)
    #run_state[:private_log] << "Grades committed to the database.\n"
    true
  end
end
