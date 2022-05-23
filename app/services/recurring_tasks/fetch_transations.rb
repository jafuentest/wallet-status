class RecurringTasks::FetchTransations
  include Delayed::RecurringJob

  run_every 12.hours
  run_at '12:00', '0:00'

  def perform # rubocop:disable Metrics/MethodLength
    Rails.logger.info 'Fetching transations'

    User.all.each do |user|
      Rails.logger.info "Fetching transations for user id: #{user.id}"
      binance = WalletBalanceService.new(user)

      Rails.logger.info "Fetching spot trades for user id: #{user.id}"
      binance.fetch_spot_trades

      Rails.logger.info "Fetching convertion trades for user id: #{user.id}"
      binance.fetch_converts

      Rails.logger.info "Fetching margin transfers for user id: #{user.id}"
      binance.fetch_margin_transfers
    end
  end
end
