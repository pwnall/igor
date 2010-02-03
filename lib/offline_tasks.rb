module OfflineTasks
  def self.do_task(task)
    print task.inspect, "\n"
    
    case task[:task]
    when 'validate'
       SubmissionValidator.validate Submission.find(task[:submission_id])
    end
  end

  def self.validate_submission(submission)
    #OfflineTasks.do_task :task => 'validate', :submission_id => submission.id
    print "Pre: #{Time.now}\n"
    STARLING.set('pushes', {:task => 'validate', :submission_id => submission.id })
    print "Post: #{Time.now}\n"
  end
end
