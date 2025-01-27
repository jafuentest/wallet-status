module TransactionFetchers::Binance
  class BaseReward < Base
    def fetch
      timestamp = start_timestamp

      loop do
        timestamp = process_batch(timestamp)
        break if timestamp.blank?
      end

      wallet.update(api_details: wallet.api_details.merge(self.class::TIMESTAMP_KEY => start_timestamp))
    end

    private

    MIN_TIMESTAMP = Time.utc(2022, 1, 1).to_datetime
    TIME_STEP = 30.days

    def process_batch(timestamp)
      transactions = fetch_transactions(timestamp)

      if transactions.empty?
        return nil if timestamp == last_fetch_timestamp

        return [timestamp - TIME_STEP, last_fetch_timestamp].max
      end

      transactions.each { |reward| create_transaction(reward) }
      ensure_progress(transactions, timestamp)
    end

    def ensure_progress(transactions, timestamp)
      last_time = if transactions.size == self.class::PAGE_SIZE
        Time.strptime(transactions.last[:time].to_s, '%Q').to_datetime
      else
        timestamp - TIME_STEP
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
        to_amount: reward[:rewards],
        timestamp: Time.strptime(reward[:time].to_s, '%Q')
      )
    rescue ActiveRecord::RecordNotUnique
      msg = "#{self.class}: Fetched existing transaction, id: #{order_id_for(reward)}, wallet_id: #{wallet.id}}"
      Rails.logger.warn(msg)
    end
  end
end
