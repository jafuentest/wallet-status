module WalletBalanceService::Margin
  def fetch_margin_transfers
    loop do
      log_margin_transfer
      break if (Time.current - start_margin_transfer) < 1.minute

      transfers = client.margin_transfer_history(start_time: start_margin_transfer, end_time: end_margin_transfer).each do |transfer|
        create_transaction_from_margin_transfer(transfer)
      end

      update_wallet_margin_transfer
    end
  end

  private

  def update_wallet_margin_transfer
    @wallet.update(api_details: @wallet.api_details.merge('margin_tranfers_last_fetch' => end_margin_transfer))
  end

  def log_margin_transfer
    Rails.logger.debug { "Fetching margin transfers between #{start_margin_transfer} and #{end_margin_transfer}" }
  end

  def start_margin_transfer
    margin_tranfers_last_fetch = @wallet.api_details['margin_tranfers_last_fetch']
    return Time.utc(2022, 1, 1).to_datetime if margin_tranfers_last_fetch.blank?

    DateTime.parse(margin_tranfers_last_fetch)
  end

  def end_margin_transfer
    [start_margin_transfer + 30.days, Time.current.to_datetime].min
  end

  def create_transaction_from_margin_transfer(transfer)
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
