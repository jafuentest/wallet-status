class RecurringTasks::FetchTransations
  include Delayed::RecurringJob

  run_every 1.day
  run_at '18:00', '6:00'

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
