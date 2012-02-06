# == Schema Information
# Schema version: 20110429122654
#
# Table name: analyzers
#
#  id             :integer(4)      not null, primary key
#  type           :string(32)      not null
#  deliverable_id :integer(4)      not null
#  message_name   :string(64)
#  db_file_id     :integer(4)
#  time_limit     :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

# Submission checker that runs an external script.
class ScriptAnalyzer < Analyzer
  # The database-backed file holding the checker script.
  belongs_to :db_file, :dependent => :destroy
  validates :db_file, :presence => true
  accepts_nested_attributes_for :db_file
  
  # Database-backed file association, including the file contents.
  def full_db_file
    DbFile.unscoped.where(:id => db_file_id).first
  end
  
  # The maximum time that the checker script is allowed to run.
  validates :time_limit, :presence => true,
                         :numericality => { :only_integer => true }

  # :nodoc: overrides Analyzer#check
  def check(submission)
    random_dir = '/tmp/' + (0...16).map { rand(256).to_s(16) }.join
    FileUtils.mkdir_p random_dir
    Dir.chdir random_dir do
      setup_script
      setup_submission submission
      setup_permissions
      run_checker_script
      
    end
    FileUtils.rm_r random_dir
  end
  
  # Copies the checker script data into the current directory.
  #
  # This should be run in a temporary directory.
  def setup_script
    script_filename = db_file.f.original_filename.split('/').last
    File.open(script_filename, 'wb') do |f|
      f.write full_db_file.f.file_contents
    end
    
    case script_filename
    when /\.tar.gz$/
      Kernel.system "tar -xzf #{script_filename}"
    when /\.tar.bz2$/
      Kernel.system "tar -xjf #{script_filename}"
    when /\.zip$/
      Kernel.system "unzip #{script_filename}"
    end
    File.unlink script_filename if File.exist?(script_filename)
  end
  
  # Copies a submission into the current directory.
  #
  # This should be run in a temporary directory.
  def setup_submission(submission)
    File.open(deliverable.filename, 'wb') do |f|
      f.write submission.full_db_file.f.file_contents
    end
  end
  
  # Configures the current directory so that every file can be executed.
  #
  # This should be run in a temporary directory meant for script execution.
  def setup_permissions
    Dir.foreach('.') do |entry|
      next if File.directory?(entry)
      File.chmod(500, entry)  
    end
  end
  
  # Runs the checker's script, assuming it is in the current directory.
  def run_checker_script
    # Fork off the runner.
    runner_pid = Kernel.fork do
      # Lobotomize ActiveRecord so it doesn't drop its connections
      ActiveRecord::Base.connection_handler.instance_variable_set :@connection_pools, {}
      
      Kernel.exec 'nice ./run.sh > ./.stdout 2> ./.stderr'
    end
    
    time_limit_seconds = (self.time_limit || 300.0).to_f
    
    # Fork off the process that enforces the time limit.
    killer_pid = Kernel.fork do
      # Lobotomize ActiveRecord so it doesn't drop its connections
      ActiveRecord::Base.connection_handler.instance_variable_set :@connection_pools, {}
      
      sleep_start = Time.now
      while (Time.now - sleep_start) < time_limit_seconds
        Kernel.sleep [2, (Time.now - sleep_start)].min
      end
      
      Zerg::Support::Process.kill_tree runner_pid
    end
    Process.detach killer_pid
    Process.wait runner_pid
    
    # Check for time-limit exceeded.
    # HACK: magic numbers
    if $?.signaled? and ($?.termsig == 15 or $?.termsig == 9)
      killed = true
    elsif $?.exited? and ($?.exitstatus == 143 or $?.exitstatus == 137)
      killed = true
    end

    # Extract score.
    stdout_text = File.read('./.stdout')
    stderr_text = File.read('./.stderr')
    begin
      stderr_diags = stderr_text.slice(0, stderr_text.index(/[\n\r]{2}/m)).split(/[\n\r]+/m)
      tests = stderr_diags.length
      passed = stderr_diags.select { |d| !(d =~ /FAIL/ || d =~ /ERROR/) }.length 
      score = "#{passed}"
      runtime = stderr_text.scan(/^Ran [0-9]* tests in ([0-9.]*)s$/)[-1]
      diagnostic = "#{passed == tests ? 'ok' : 'needs work'} (#{passed} / #{tests})"
      if runtime != nil
        diagnostic += " in %.1fs" % runtime[0]
      end
    rescue
      score = '0'
      # Check both ways that we might know about the runner getting killed
      if killed
        diagnostic = 'time limit exceeded (%.2f s)' % time_limit_seconds
      else
        diagnostic = 'runtime errors'
      end
    end
    
    # update results
    ActiveRecord::Base.verify_active_connections!
    result = submission.analysis
    result.stdout = stdout_text
    result.stderr = stderr_text
    result.diagnostic = diagnostic
    result.score = score
    result.save!
  end
end
