class TransactionFetchers::Binance::Convertion < TransactionFetchers::Binance::Base
  def fetch
    loop do
      log_fetch
      break if (Time.current - start_time) < 1.minute

      client.convert_trade_flow(start_time:, end_time:).each do |convertion|
        create_transaction(convertion)
      end

      update_wallet
    end
  end

  private

  def update_wallet
    wallet.update(api_details: wallet.api_details.merge('convertions_last_fetch' => end_time))
  end

  def log_fetch
    Rails.logger.debug { "Fetching convert trades between #{start_time} and #{end_time}" }
  end

  def start_time
    convertions_last_fetch = wallet.api_details['convertions_last_fetch']
    return Time.utc(2022, 1, 1).to_datetime if convertions_last_fetch.blank?

    DateTime.parse(convertions_last_fetch)
  end

  def end_time
    [start_time + 30.days, Time.current.to_datetime].min
  end

  def create_transaction(convertion)
    return unless convertion[:orderStatus] == 'SUCCESS'

    wallet.transactions.convertions.create!(
      from_asset: convertion[:fromAsset], from_amount: convertion[:fromAmount],
      to_asset: convertion[:toAsset], to_amount: convertion[:toAmount],
      timestamp: Time.strptime(convertion[:createTime].to_s, '%Q'),
      order_id: convertion[:orderId]
    )
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.warn "Fetched existing transaction, order_id: #{convertion[:orderId]}, wallet_id: #{wallet.id}}"
  end
end
