Delayed::Worker.destroy_failed_jobs = false
silence_warnings do
  Delayed::Job.const_set 'MAX_ATTEMPTS', 3
  Delayed::Job.const_set 'MAX_RUN_TIME', 1.hour
end
