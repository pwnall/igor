require 'fileutils'
require 'net/http'
require 'uri'

module SubmissionValidator
  def self.validate(submission)
    # retrieve the validation method
    deliverable_validation = submission.deliverable.deliverable_validation
    if deliverable_validation.nil?
      submission.run_result.diagnostic = 'no validation available'
      submission.run_result.save!
      return
    else
      submission.run_result.diagnostic = 'running'
      submission.run_result.save!      
    end
    
    # delegate to validation-specific code
    case deliverable_validation
    when ProcValidation
      SubmissionValidator.send deliverable_validation.message_name.to_sym, submission, deliverable_validation
    when UploadedScriptValidation
      SubmissionValidator.validate_script submission, deliverable_validation
    else
      submission.run_result.diagnostic = 'not implemented'
      submission.run_result.save!
    end
  end

  def self.validate_pdf(submission, deliverable_validation)
    file_contents = submission.code.file_contents
    if file_contents[0...5] == '%PDF-' && file_contents[-1024..-1] =~ /\%\%EOF/
      submission.run_result.diagnostic = 'valid PDF'
      submission.run_result.stdout = 'valid PDF header and trailer encountered'
      submission.run_result.stderr = ''
      submission.run_result.save!
    else
      submission.run_result.diagnostic = 'bad PDF'
      submission.run_result.stdout = ''
      submission.run_result.stderr = "the file you have submitted is not a legal PDF file"
      submission.run_result.save!
    end
  end
  
  def self.validate_script(submission, deliverable_validation)
    # setup
    random_dir = '/tmp/' + (0...16).map { rand(256).to_s(16) }.join
    Dir.mkdir(random_dir)     
    File.open(File.join(random_dir, submission.filename), 'w') do |f|
      f.write submission.code.file_contents
    end    
    script_filename = deliverable_validation.original_filename.split('/').last
    
    tls = deliverable_validation.time_limit
    time_limit = tls.nil? ? nil : tls.to_f
    time_limit ||= 300.0
    
    # daemonize the sub-thread -- need to do it ourselves 'cause rails can't exit!() -- Kernel.daemonize uses exit()... 'tarded
=begin
      Process.setsid
      Kernel.fork and Kernel.exit!
      ObjectSpace.each_object(IO) { |io| io.close rescue nil }
=end
      Dir.chdir(random_dir)
=begin
      STDIN.reopen '/dev/null'
      STDOUT.reopen '_out', 'a'
      STDERR.reopen '_err', 'a'
=end
      
    #
    # lengthy setup
    #      
    # fetch package
    File.open(script_filename, 'w') do |f|
      if deliverable_validation.pkg.file_contents
        f.write deliverable_validation.pkg.file_contents
      else        
        uri = URI.parse deliverable_validation.file_url
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.get(uri.path) { |body_chunk| f.write body_chunk }
        end
      end
    end
    # unpack package
    case script_filename
    when /\.tar.gz$/
      Kernel.system "tar -xzf #{script_filename}"
      # File.rm script_filename
    when /\.tar.bz2$/
      Kernel.system "tar -xjf #{script_filename}"
    end
    
    # mark files as executable, so the shell script can be run (and so it can run whatever it likes)
    Dir.foreach('.') do |entry|
      next if entry == '.' || entry == '..'
      File.chmod(500, entry)  
    end
    
    # fork off the runner
    runner_pid = Kernel.fork do
      # Lobotomize ActiveRecord so it doesn't drop its connections
      ActiveRecord::Base.connection_handler.instance_variable_set :@connection_pools, {}
      
      Kernel.exec 'nice ./run.sh > ./.stdout 2> ./.stderr'
    end      
    # fork off the process which will kill the runner if it runs out of time
    killer_pid = Kernel.fork do
      # Lobotomize ActiveRecord so it doesn't drop its connections
      ActiveRecord::Base.connection_handler.instance_variable_set :@connection_pools, {}
      
      sleep_start = Time.now
      while (Time.now - sleep_start) < time_limit
        Kernel.sleep [2, (Time.now - sleep_start)].min
      end
      
      Zerg::Support::Process.kill_tree runner_pid
    end
    Process.detach(killer_pid)
    Process.wait(runner_pid)
    # If the runner died due to SIGTERM or SIGKILL...
    # XXX magic numbers
    if $?.signaled? and ($?.termsig == 15 or $?.termsig == 9)
      killed = true
    elsif $?.exited? and ($?.exitstatus == 143 or $?.exitstatus == 137)
      killed = true
    end

    # score
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
        diagnostic = 'time limit exceeded (%ds)' % time_limit
      else
        diagnostic = 'runtime errors'
      end
    end
    
    # update results
    ActiveRecord::Base.verify_active_connections!
    submission.run_result.stdout = stdout_text
    submission.run_result.stderr = stderr_text
    submission.run_result.diagnostic = diagnostic
    submission.run_result.score = score
    submission.run_result.save!
        
    # cleanup
    Dir.chdir '..' # step out of the temp mess so we can clean it up
    FileUtils.rm_r random_dir        
  end
end
