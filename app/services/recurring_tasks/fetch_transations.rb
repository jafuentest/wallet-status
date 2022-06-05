class RecurringTasks::FetchTransations
  include Delayed::RecurringJob

  run_every 12.hours
  run_at '12:00', '0:00'

  def perform
    Rails.logger.info 'Creating fetch transations jobs'

    User.all.each do |user|
      binance = WalletBalanceService.new(user)

      binance.delay.fetch_spot_trades
      binance.delay.fetch_converts
      binance.delay.fetch_margin_transfers
    end
  end
end
