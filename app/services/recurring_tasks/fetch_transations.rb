class RecurringTasks::FetchTransations
  include Delayed::RecurringJob

  FETCHER_CLASSES = [
    TransactionFetchers::Binance::Convertion,
    TransactionFetchers::Binance::Margin,
    TransactionFetchers::Binance::Spot,
  ]

  run_every 1.day
  run_at '18:00', '6:00'

  def perform
    Rails.logger.info 'Creating fetch transations jobs'

    User.find_each do |user|
      user.wallets.each do |wallet|
        FETCHER_CLASSES.each do |fetcher_class|
          fetcher_class.new(wallet).delay.fetch
        end
      end
    end
  end
end
