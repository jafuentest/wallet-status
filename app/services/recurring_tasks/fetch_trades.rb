class RecurringTasks::FetchTrades
  include Delayed::RecurringJob

  run_every 12.hours
  run_at '08:00', '20:00'

  def perform
    User.all.each do |user|
      Logger.warn "Recurring user #{user}"
    end
  end
end
