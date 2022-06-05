module WalletBalanceService::Convert
  def fetch_converts
    loop do
      log_convert
      break if (Time.current - start_convert) < 1.minute

      converts = client.convert_trade_flow(
        recvWindow: 60_000,
        startTime: start_convert.strftime('%Q'), endTime: end_convert.strftime('%Q')
      )

      converts[:list].each { |convertion| create_transaction_from_convertion(convertion) }
      update_wallet
    end
  end

  private

  def update_wallet
    @wallet.update(api_details: @wallet.api_details.merge('convertions_last_fetch' => end_convert))
  end

  def log_convert
    Rails.logger.debug { "Fetching convert trades between #{start_convert} and #{end_convert}" }
  end

  def start_convert
    convertions_last_fetch = @wallet.api_details['convertions_last_fetch']
    return Time.utc(2022, 1, 1).to_datetime if convertions_last_fetch.blank?

    DateTime.parse(convertions_last_fetch)
  end

  def end_convert
    [start_convert + 30.days, Time.current.to_datetime].min
  end

  def create_transaction_from_convertion(convertion)
    return unless convertion[:orderStatus] == 'SUCCESS'

    @wallet.transactions.convertions.create!(
      from_asset: convertion[:fromAsset], from_amount: convertion[:fromAmount],
      to_asset: convertion[:toAsset], to_amount: convertion[:toAmount],
      timestamp: Time.strptime(convertion[:createTime].to_s, '%Q'),
      order_id: convertion[:orderId]
    )
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.warn "Fetched existing transaction, order_id: #{convertion[:orderId]}, wallet_id: #{@wallet.id}}"
  end
end
