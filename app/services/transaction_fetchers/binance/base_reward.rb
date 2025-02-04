module TransactionFetchers::Binance
  class BaseReward < Base
    def self.amount_key
      raise NotImplementedError, "#{self} must implement `amount_key`"
    end

    private

    MIN_TIMESTAMP = Time.utc(2022, 1, 1).to_datetime
    MAX_TIME_RANGE = 90.days

    def ensure_progress(transactions, timestamp)
      return timestamp - MAX_TIME_RANGE if transactions.blank?

      # If we fetched the maximum number of transactions, we can't fetch the next
      # time interval, or we'll be missing the transactions in between.
      if transactions.size == self.class::PAGE_SIZE
        # Subtract 1 second to avoid fetching the last transaction again
        return Time.zone.at(transactions.last[:time] / 1000).to_datetime - 1.second
      end

      timestamp - MAX_TIME_RANGE
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
      transaction_creator.create!(
        order_id: order_id_for(reward),
        to_asset: reward[:asset],
        to_amount: reward[self.class.amount_key],
        timestamp: Time.zone.at(reward[:time] / 1000).to_datetime
      )
    rescue ActiveRecord::RecordNotUnique
      msg = "#{self.class}: Fetched existing transaction, id: #{order_id_for(reward)}, wallet_id: #{wallet.id}"
      Rails.logger.warn(msg)
    end

    def transaction_creator
      raise NotImplementedError, "#{self.class} must implement `transaction_creator`"
    end
  end
end
