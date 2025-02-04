module TransactionFetchers::Binance
  class BaseReward < Base
    protected

    MIN_TIMESTAMP = Time.utc(2022, 1, 1).to_datetime
    MAX_TIME_RANGE = 90.days

    def ensure_progress(transactions, timestamp)
      last_time = if transactions.size == self.class::PAGE_SIZE
        Time.strptime((transactions.last[:time] - 1).to_s, '%Q').to_datetime
      else
        timestamp - MAX_TIME_RANGE
      end
      last_time -= 1.second if last_time == timestamp
      last_time
    end

    def last_fetch_timestamp
      return @last_fetch_timestamp if defined?(@last_fetch_timestamp)

      timestamp_str = wallet.api_details[self.class::TIMESTAMP_KEY]
      date_time = timestamp_str.present? ? DateTime.parse(timestamp_str) : MIN_TIMESTAMP
      @last_fetch_timestamp = date_time
    end

    def start_timestamp
      return @start_timestamp if defined?(@start_timestamp)

      @start_timestamp = Time.current.to_datetime
    end

    def create_transaction(reward)
      wallet.transactions.create!(
        order_id: order_id_for(reward),
        order_type: self.class::ORDER_TYPE,
        to_asset: reward[:asset],
        to_amount: reward[self.class::AMOUNT_KEY],
        timestamp: Time.strptime(reward[:time].to_s, '%Q')
      )
    rescue ActiveRecord::RecordNotUnique
      msg = "#{self.class}: Fetched existing transaction, id: #{order_id_for(reward)}, wallet_id: #{wallet.id}}"
      Rails.logger.warn(msg)
    end
  end
end
