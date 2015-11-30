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
      numericality: { greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :map_time_limit

  # Maximum number of megabytes of RAM that the student's code can use.
  validates :map_ram_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :map_ram_limit

  # Maximum megabytes of container logging that the student's code can produce.
  validates :map_logs_limit, presence: true,
      numericality: { greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :map_logs_limit

  # Maximum number of seconds of CPU time that the grading code can use.
  validates :reduce_time_limit, presence: true,
      numericality: { greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :reduce_time_limit

  # Maximum number of megabytes of RAM that the grading code can use.
  validates :reduce_ram_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :reduce_ram_limit

  # Maximum megabytes of container logging that the grading code can produce.
  validates :reduce_logs_limit, presence: true,
      numericality: { greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :reduce_logs_limit

  # Convert strings to numbers.
  def map_time_limit=(new_value)
    super new_value && new_value.to_f
  end
  def map_time_limit
    # TODO(pwnall): All the getter overrides can go away if we can make sure
    #               that the database only stores numbers.
    value = super
    value && value.to_f
  end
  def map_ram_limit=(new_value)
    super new_value && new_value.to_i
  end
  def map_ram_limit
    value = super
    value && value.to_i
  end
  def map_logs_limit=(new_value)
    super new_value && new_value.to_f
  end
  def map_logs_limit
    value = super
    value && value.to_f
  end
  def reduce_time_limit=(new_value)
    super new_value && new_value.to_f
  end
  def reduce_time_limit
    value = super
    value && value.to_f
  end
  def reduce_ram_limit=(new_value)
    super new_value && new_value.to_i
  end
  def reduce_ram_limit
    value = super
    value && value.to_i
  end
  def reduce_logs_limit=(new_value)
    super new_value && new_value.to_f
  end
  def reduce_logs_limit
    value = super
    value && value.to_f
  end

  # :nodoc: overrides Analyzer#analyze
  def analyze(submission)
    analysis = submission.analysis

    mr_job = run_submission submission
    analysis.status = extract_status mr_job
    analysis.scores = extract_grades mr_job
    analysis.log = mr_job.reducer_runner.stdout
    analysis.private_log = mr_job.reducer_runner.stderr
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
      'mapper' => {
        'wait_time' => map_time_limit,
        'ram' => map_ram_limit,
        'swap' => 0,
        'logs' => map_logs_limit,
        'vcpus' => 1,
        'ulimits' => { 'cpu' => map_time_limit.ceil } },
      'reducer' => {
        'wait_time' => reduce_time_limit,
        'ram' => reduce_ram_limit,
        'logs' => reduce_logs_limit,
        'swap' => 0,
        'vcpus' => 1,
        'ulimits' => { 'cpu' => reduce_time_limit.ceil } },
    }

    # NOTE: We release the ActiveRecord connection because we won't use it for
    #       a while. All AR queries in this method should be done above this
    #       comment.
    ActiveRecord::Base.clear_active_connections!

    template = ContainedMr.new_template 'alg_mr', job_id, template_io
    job = template.new_job job_id, job_options

    job.build_mapper_image submission_string
    1.upto job.item_count do |i|
      job.run_mapper i
    end
    job.build_reducer_image
    job.run_reducer
    job.destroy!
    template.destroy!

    job
  end

  # Extracts the grades produced by a Map-Reduce job.
  #
  # @param {ContainedMr::Job} mr_job the job that produced the grades
  # @return {Hash<String, Number>} JSON grades output by the Map-Reduce job
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
      :limit_exceeded
    else
      :ok
    end
  end
end
