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

# Submission checker that runs an external script.
class ScriptAnalyzer < Analyzer
  include HasDbFile

  # Limits that apply when running the analyzer script.
  store :exec_limits, coder: JSON

  # Maximum number of seconds of CPU time that the analyzer can use.
  validates :time_limit,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :time_limit

  # Maximum number of megabytes of RAM that the analyzer can use.
  validates :ram_limit,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :ram_limit

  # Maximum number of file descriptors that the analyzer can use.
  validates :file_limit,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :file_limit

  # Maximum number of megabytes that the analyzer can write to a single file.
  validates :file_size_limit,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :file_size_limit

  # Maximum number of processes that the analyzer can use.
  validates :process_limit,
      numericality: { only_integer: true, greater_than: 0, allow_nil: false }
  store_accessor :exec_limits, :process_limit

  # :nodoc: overrides Analyzer#analyze
  def analyze(submission)
    Dir.mktmpdir 'seven_' do |temp_dir|
      Dir.chdir temp_dir do
        manifest = unpack_script
        if manifest
          ext_key = write_submission submission, manifest
          if ext_key
            write_grading_key manifest
            run_state = run_script manifest, ext_key
            grading = extract_grading run_state, manifest, ext_key
            outcome = extract_outcome run_state, manifest, ext_key
            if auto_grading?
              unless update_grades submission, grading, run_state
                outcome[:status] = :analyzer_bug
                outcome[:log] << "\nThe analyzer issued incorrect grades."
              end
            else
              run_state[:private_log] << "Auto grading NOT enabled.\n"
            end
            update_submission submission, run_state, outcome
          else
            setup_error submission, 'Unsupported submission file format', :wrong
          end
        else
          setup_error submission, 'Failed to parse the analyzer manifest'
        end
      end
    end
  end

  # Copies the checker script data into the current directory.
  #
  # This should be run in a temporary directory.
  #
  # Returns a hash containing the parsed script configuration.
  def unpack_script
    Zip::File.open_buffer contents do |zip|
      zip.each do |entry|
        file_dir = File.dirname entry.name
        FileUtils.mkdir_p file_dir unless file_dir.empty?
        entry.extract entry.name unless File.exist?(entry.name)
      end
    end

    begin
      manifest = File.open('analyzer.yml') { |f| YAML.load f }
    rescue
      # The analyzer.yml manifest doesn't exist, or doesn't parse.
      return nil
    end
    return nil unless manifest.kind_of?(Hash)

    # Remove files with names matching the submission files.
    manifest.keys.each do |key|
      next unless key[0] == ?. && manifest[key]['get']
      File.unlink manifest[key]['get'] if File.exist? manifest[key]['get']
    end
    manifest
  end

  # Copies a submission into the current directory.
  #
  # This should be run in a temporary directory.
  #
  # Returns the manifest key matching the submission's extension.
  def write_submission(submission, manifest)
    paperclip = submission.db_file.f
    ext_key = File.extname(paperclip.original_filename)
    return nil unless manifest[ext_key] && manifest[ext_key]['get']
    File.open manifest[ext_key]['get'], 'wb' do |f|
      f.write paperclip.file_contents
    end
    ext_key
  end

  # Creates a grading key and a file containing it.
  #
  # The grading key is created only if the manifest indicates that the analyzer
  # can handle a grading key.
  def write_grading_key(manifest)
    if manifest['grading'] && manifest['grading']['key']
      manifest[:grading_key] = SecureRandom.base64 64
      File.open manifest['grading']['key'], 'w' do |f|
        f.write manifest[:grading_key]
      end
    end
  end

  # Runs the checker's script, assuming it is in the current directory.
  def run_script(manifest, ext_key)
    connection = ActiveRecord::Base.remove_connection
    run_command = Shellwords.split(manifest[ext_key]['run'] || '')
    begin
      File.open('.log', 'w') { |f| f.write '' }
      io = { in: '/dev/null', out: '.log', err: STDOUT }
      limits = { cpu: time_limit.to_i + 1,
            file_size: file_size_limit.to_i.megabytes,
            open_files: 10 + file_limit.to_i,
            data: ram_limit.to_i.megabytes
          }

      pid = ExecSandbox::Spawn.spawn nice_command + run_command, io, {}, limits

      # TODO(pwnall): kill the main process from a thread, so we don't waste
      #               0.1 seconds for instant submissions
      start_time = Time.current
      status = nil
      loop do
        elapsed_time = Time.current - start_time
        time_left = time_limit.to_i + 1 - elapsed_time
        if time_left < 0
          if time_left < -1
            # The process should really be done.
            Process.kill 'KILL', pid rescue nil
          else
            # The process should be done.
            Process.kill 'TERM', pid rescue nil
          end
        end

        Kernel.sleep 0.1
        status = ExecSandbox::Wait4.wait4_nonblock pid
        break unless status.nil?
      end
      log = File.exist?('.log') ? File.read('.log') : 'Program removed its log'

      # Force the output to UTF-8 if necessary.
      unless log.valid_encoding? && log.encoding == Encoding::UTF_8
        log.encode! Encoding::UTF_16, invalid: :replace, undef: :replace
        log.encode! Encoding::UTF_8
      end

      { log: log, status: status, private_log: '' }
    ensure
      ActiveRecord::Base.establish_connection connection || {}
    end
  end

  # Extracts the grading output from a script's run result.
  #
  # Returns a hash containing the processed grading information.
  def extract_grading(run_state, manifest, ext_key)
    if manifest['grading']
      run_state[:private_log] << "Grading enabled in the manifest.\n"
      defaults = manifest['grading']['defaults'] || {}
    else
      run_state[:private_log] << "Grading NOT enabled in the manifest.\n"
      defaults = nil
    end
    unless manifest[:grading_key]
      unless defaults.nil?
        run_state[:private_log] <<
            "The manifest doesn't specify the grading key file name!\n"
        run_state[:private_log] << "Used the default grades.\n"
      end

      return defaults
    end

    splitter = "\n#{manifest[:grading_key]}\n"
    log, match, grading_json = run_state[:log].partition splitter
    unless match == splitter
      if run_state[:log].index manifest[:grading_key]
        run_state[:private_log] <<
          "Grading script did not output the grading key on its own line!\n"
      else
        run_state[:private_log] <<
          "Grading script did not output the grading key!\n"
      end
      run_state[:private_log] << "Used the default grades.\n"
      return defaults
    end

    run_state[:log] = log
    run_state[:private_log] << "JSON grades output by the grading script:\n"
    run_state[:private_log] << "--- begin JSON object ---\n"
    run_state[:private_log] << grading_json
    run_state[:private_log] << "--- end JSON object ---\n"
    begin
      grades = JSON.parse grading_json.strip.split("\n", 2).first
      run_state[:private_log] << "JSON grades parsed successfully.\n"
      grades
    rescue JSONError => e
      run_state[:private_log] <<
          "Failed to parse grading JSON: #{e.class.name} - #{e.message}\n"
      run_state[:private_log] << e.backtrace.join("\n") + "\n"
      run_state[:private_log] << "Used the default grades.\n"
      defaults
    end
  end

  # Computes the analysis outcome based on a script's run result.
  def extract_outcome(run_state, manifest, ext_key)
    running_time =
        run_state[:status][:system_time] + run_state[:status][:user_time]
    if running_time > time_limit.to_i
      status = :limit_exceeded
      status_log = <<END_LOG
Your submission exceeded the time limit of #{time_limit.to_i} seconds.
The analysis was terminated after running for #{running_time} seconds.
END_LOG
    elsif run_state[:status][:exit_code] != 0
      status = :crashed
      status_log = <<END_LOG
Your submission crashed with exit code #{run_state[:status][:exit_code]}.
The analysis ran for #{running_time} seconds.
END_LOG
    else
      status = :ok
      status_log = <<END_LOG
Your submission appears to be correct.
The analysis ran for #{running_time} seconds.
END_LOG
    end
    { status: status, log: status_log }
  end

  # Update a submission's analysis based on the script's result.
  def update_submission(submission, run_state, outcome)
    log = run_state[:log]
    log_limit = Analysis::LOG_LIMIT - 1.kilobyte
    if log.length >= log_limit
      log = [log[0, log_limit], "\n**Too much output. Truncated.**"].join('')
    end

    private_log = run_state[:private_log]
    private_log_limit = Analysis::LOG_LIMIT - 128
    if private_log.length >= private_log_limit
      private_log = [private_log[0, private_log_limit],
                     "\n**Too much output. Truncated.**"].join('')
    end

    analysis = submission.analysis
    analysis.log = [log, outcome[:log]].join("\n")
    analysis.private_log = private_log
    analysis.status = outcome[:status]
    analysis.save!
  end

  # Reports an error that happened before the submission got to run.
  def setup_error(submission, message, status = :analyzer_bug)
    analysis = submission.analysis
    analysis.log = message + "\n"
    analysis.status = status
    analysis.save!
  end

  # Updates the database with the grades issued by the script.
  #
  # @return {Boolean} true if the database is updated; false if validation
  #   error occurred and grades were not changed
  def update_grades(submission, grading, run_state)
    assignment = submission.assignment
    grades = []
    grading.each do |metric_name, score_fraction|
      metric = assignment.metrics.where(name: metric_name).first
      unless metric
        run_state[:private_log] << "Metric not found: #{metric_name}\n"
        next
      end
      grade = metric.grade_for submission.subject
      grade.score = score_fraction * metric.max_score
      grade.grader = User.robot
      unless grade.valid?
        run_state[:private_log] <<
            "Produced invalid grade for metric #{metric_name}\n"
        run_state[:private_log] << grade.errors.messages.inspect + "\n"
        return false
      end
      grades << grade
    end
    grades.each(&:save!)
    run_state[:private_log] << "Grades committed to the database.\n"
    true
  end

  # The command for nice-ing processes on the current platform.
  #
  # Returns an array of shell-parsed tokens that make up the command for running
  # a process with low scheduler priority.
  def nice_command
    case RUBY_PLATFORM
    when /darwin/
      command = ['nice', '-n', '20']
    when /linux/
      command = ['nice', '--adjustment=20']
    else
      command = ['nice']
    end
  end
end
