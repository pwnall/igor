# == Schema Information
#
# Table name: analyzers
#
#  id             :integer          not null, primary key
#  deliverable_id :integer          not null
#  type           :string(32)       not null
#  auto_grading   :boolean          default(FALSE), not null
#  exec_limits    :text
#  db_file_id     :integer
#  message_name   :string(64)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# Submission checker that runs an external script.
class ScriptAnalyzer < Analyzer
  # The database-backed file holding the analyzer script.
  belongs_to :db_file, dependent: :destroy
  validates :db_file, presence: true
  validates_associated :db_file
  accepts_nested_attributes_for :db_file
  attr_accessible :db_file_attributes
  
  # Database-backed file association, including the file contents.
  def full_db_file
    DbFile.unscoped.where(id: db_file_id).first
  end
  
  # Limits that apply when running the analyzer script.
  store :exec_limits
  
  # Maximum number of seconds of CPU time that the analyzer can use.
  validates :time_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0 }
  store_accessor :exec_limits, :time_limit
  attr_accessible :time_limit

  # Maximum number of megabytes of RAM that the analyzer can use.
  validates :ram_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0 }
  store_accessor :exec_limits, :ram_limit
  attr_accessible :ram_limit
    
  # Maximum number of file descriptors that the analyzer can use.
  validates :file_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0 }
  store_accessor :exec_limits, :file_limit
  attr_accessible :file_limit

  # Maximum number of megabytes that the analyzer can write to a single file.
  validates :file_size_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0 }
  store_accessor :exec_limits, :file_size_limit
  attr_accessible :file_size_limit
  
  # Maximum number of processes that the analyzer can use.
  validates :process_limit, presence: true,
      numericality: { only_integer: true, greater_than: 0 }
  store_accessor :exec_limits, :process_limit
  attr_accessible :process_limit

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
            update_grades submission, grading if auto_grading?
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
    package_file = Tempfile.new 'seven_package_'
    package_file.close
    File.open package_file.path, 'wb' do |f|
      f.write full_db_file.f.file_contents
    end
    
    Zip::ZipFile.open package_file.path do |zip_file|
      zip_file.each do |f|
        next if f.name.index '..'
        f_dir = File.dirname f.name
        FileUtils.mkdir_p f_dir unless f_dir.empty?
        zip_file.extract f, f.name unless File.exist?(f.name)
      end
    end
    package_file.unlink

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
    paperclip = submission.full_db_file.f
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
           
      status = ExecSandbox::Wait4.wait4 pid
      log = File.exist?('.log') ? File.read('.log') : 'Program removed its log'
      
      # Force the output to UTF-8 if necessary.
      unless log.valid_encoding? && log.encoding == Encoding::UTF_8
        log.encode! Encoding::UTF_16, invalid: :replace, undef: :replace
        log.encode! Encoding::UTF_8
      end
      
      { log: log, status: status }
    ensure
      ActiveRecord::Base.establish_connection connection || {}
    end
  end
  
  # Extracts the grading output from a script's run result.
  #
  # Returns a hash containing the processed grading information.
  def extract_grading(run_state, manifest, ext_key)
    if manifest['grading']
      defaults = manifest['grading']['defaults'] || {}
    end
    return defaults unless manifest[:grading_key]
    splitter = "\n#{manifest[:grading_key]}\n"
    log, match, grading_json = run_state[:log].rpartition manifest[:grading_key]
    return defaults unless match == manifest[:grading_key]
    run_state[:log] = log
    begin
      JSON.parse grading_json.strip.split("\n", 2).first
    rescue
      defaults
    end
  end
    
  # Computes the analysis outcome based on a script's run result.
  def extract_outcome(run_state, manifest, ext_key)
    running_time = run_state[:status][:system_time] + run_state[:status][:user_time]
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
  def update_submission(submission, result, outcome)
    log = result[:log]
    log_limit = Analysis::LOG_LIMIT - 1.kilobyte
    if log.length >= log_limit
      log = [log[0, log_limit], "\n**Too much output. Truncated.**"].join('')
    end
    
    analysis = submission.analysis
    analysis.log = [log, outcome[:log]].join("\n")
    analysis.status = outcome[:status]
    analysis.save!
  end
  
  # Reports an error that happened before the submission got to run.
  def setup_error(submission, message, status = :no_analyzer)
    analysis = submission.analysis
    analysis.log = message + "\n"
    analysis.status = status
    analysis.save!
  end
  
  def update_grades(submission, grading)
    assignment = submission.assignment
    grading.each do |metric_name, score_fraction|
      metric = assignment.metrics.where(name: metric_name).first
      next unless metric
      grade = metric.grade_for submission.subject
      grade.score = score_fraction * metric.max_score
      grade.grader = User.robot
      grade.save!
    end
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
