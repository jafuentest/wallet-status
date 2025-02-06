module TransactionFetchers::Binance
  class BaseReward < Base
    MAX_TIME_RANGE = 90.days

    def self.amount_key
      raise NotImplementedError, "#{self} must implement `amount_key`"
    end

    def self.order_id_for(*)
      raise NotImplementedError, "#{self} must implement `order_id_for`"
    end

    private

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
      return @last_fetch_timestamp if @last_fetch_timestamp.present?

      timestamp_str = wallet.api_details[self.class::TIMESTAMP_KEY]
      date_time = timestamp_str.present? ? DateTime.parse(timestamp_str) : MIN_TIMESTAMP
      @last_fetch_timestamp = date_time
    end

    def start_timestamp
      @start_timestamp ||= Time.current.to_datetime
    end

    def create_transaction(reward)
      order_id = self.class.order_id_for(reward)
      transaction_creator.create!(
        order_id: order_id,
        to_asset: reward[:asset],
        to_amount: reward[self.class.amount_key],
        timestamp: Time.zone.at(reward[:time] / 1000).to_datetime
      )
    rescue ActiveRecord::RecordNotUnique
      msg = "#{self.class}: Fetched existing transaction, id: #{order_id}, wallet_id: #{wallet.id}"
      Rails.logger.warn(msg)
    end

    def transaction_creator
      raise NotImplementedError, "#{self.class} must implement `transaction_creator`"
    end
  end
end
