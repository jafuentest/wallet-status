class TransactionFetchers::Binance::Margin < TransactionFetchers::Binance::Base
  def fetch
    loop do
      log_fetch
      break if (Time.current - start_time) < 1.minute

      transfers = client.margin_transfer_history(start_time:, end_time:).each do |transfer|
        create_transaction(transfer)
      end

      update_wallet
    end
  end

  private

  def update_wallet
    @wallet.update(api_details: @wallet.api_details.merge('margin_tranfers_last_fetch' => end_time))
  end

  def log_fetch
    Rails.logger.debug { "Fetching margin transfers between #{start_time} and #{end_time}" }
  end

  def start_time
    margin_tranfers_last_fetch = @wallet.api_details['margin_tranfers_last_fetch']
    return Time.utc(2022, 1, 1).to_datetime if margin_tranfers_last_fetch.blank?

    DateTime.parse(margin_tranfers_last_fetch)
  end

  def end_time
    [start_time + 30.days, Time.current.to_datetime].min
  end

  def create_transaction(transfer)
    return unless transfer[:status] == 'CONFIRMED'

    transfer_type = transfer[:type] == 'ROLL_IN' ? :from : :to

    @wallet.transactions.margin_transfers.create!(
      "#{transfer_type}_asset" => transfer[:asset],
      "#{transfer_type}_amount" => transfer[:amount],
      timestamp: Time.strptime(transfer[:timestamp].to_s, '%Q'),
      order_id: transfer[:txId]
    )
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.warn "Fetched existing margin transfer, order_id: #{transfer[:txId]}, wallet_id: #{@wallet.id}}"
  end
end
