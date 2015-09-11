Rails.application.config.active_job.queue_adapter = :delayed_job

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 2
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 4.hours
# Delayed::Worker.read_ahead = 5
# Delayed::Worker.default_queue_name = 'default'

if Rails.env.development? && !ENV['DELAY_JOBS']
  Delayed::Worker.delay_jobs = false
else
  Delayed::Worker.delay_jobs = true
end
#Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
