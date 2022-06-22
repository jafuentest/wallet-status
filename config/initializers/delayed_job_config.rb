Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 5
Delayed::Worker.delay_jobs = Rails.env.production?
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))

# Delayed::Worker.sleep_delay = 60
# Delayed::Worker.max_run_time = 5.minutes
# Delayed::Worker.read_ahead = 10
# Delayed::Worker.default_queue_name = 'default'
# Delayed::Worker.raise_signal_exceptions = :term
