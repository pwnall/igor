require 'fileutils'
require 'net/http'
require 'uri'

module SubmissionChecker
  def self.validate(submission)
    checker = submission.deliverable.submission_checker
    if checker
      submission.check_result.diagnostic = 'running'
      submission.check_result.save!      
    else
      submission.check_result.diagnostic = 'no submission checker available'
      submission.check_result.save!
      return
    end
    
    case checker
    when ProcChecker
      SubmissionChecker.send checker.message_name.to_sym, submission, checker
    when ScriptChecker
      SubmissionChecker.run_checker_script submission, checker
    end
  end

  def self.validate_pdf(submission, checker)
    file_contents = submission.code.file_contents
    if file_contents[0...5] == '%PDF-' && file_contents[-1024..-1] =~ /\%\%EOF/
      submission.check_result.diagnostic = 'valid PDF'
      submission.check_result.stdout = 'valid PDF header and trailer encountered'
      submission.check_result.stderr = ''
      submission.check_result.save!
    else
      submission.check_result.diagnostic = 'bad PDF'
      submission.check_result.stdout = ''
      submission.check_result.stderr = "the file you have submitted is not a legal PDF file"
      submission.check_result.save!
    end
  end
  
  def self.run_checker_script(submission, checker)
    # setup
    random_dir = '/tmp/' + (0...16).map { rand(256).to_s(16) }.join
    Dir.mkdir(random_dir)     
    
    time_limit = (checker.time_limit || 300.0).to_f
    
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
    script_filename = checker.pkg.original_filename.split('/').last
    File.open(script_filename, 'w') do |f|
      f.write checker.pkg.file_contents
    end
    
    # unpack package
    case script_filename
    when /\.tar.gz$/
      Kernel.system "tar -xzf #{script_filename}"
      File.unlink script_filename if File.exist?(script_filename)
    when /\.tar.bz2$/
      Kernel.system "tar -xjf #{script_filename}"
      File.unlink script_filename if File.exist?(script_filename)
    when /\.zip$/
      Kernel.system "unzip #{script_filename}"
      File.unlink script_filename if File.exist?(script_filename)
    end

    # inject submission into package
    File.open(File.join(random_dir, submission.deliverable.filename), 'w') do |f|
      f.write submission.code.file_contents
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
    # HACK: magic numbers
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
    submission.check_result.stdout = stdout_text
    submission.check_result.stderr = stderr_text
    submission.check_result.diagnostic = diagnostic
    submission.check_result.score = score
    submission.check_result.save!
        
    # cleanup
    Dir.chdir '..' # step out of the temp mess so we can clean it up
    FileUtils.rm_r random_dir        
  end
end
