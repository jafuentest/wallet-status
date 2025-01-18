class RecurringTasks::FetchTransations
  include Delayed::RecurringJob

  run_every 1.day
  run_at '18:00', '6:00'

  def perform
    Rails.logger.info 'Creating fetch transations jobs'

    User.find_each do |user|
      user.wallets.each do |wallet|
        wallet.fetcher_classes.each do |fetcher_class|
          fetcher_class.new(wallet).delay.fetch
        end
      end
    end
  end
end
