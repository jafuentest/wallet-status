module TransactionFetchers::Binance
  class FlexibleReward < Base
    MIN_TIMESTAMP = Time.utc(2022, 1, 1).to_datetime
    PAGE_SIZE = 10
    TIMESTAMP_KEY = 'flexible_last_fetch'.freeze

    def fetch
      timestamp = start_timestamp

      loop do
        timestamp = process_batch(timestamp)
        break if timestamp.blank?
      end

      wallet.update(api_details: wallet.api_details.merge(TIMESTAMP_KEY => start_timestamp))
    end

    private

    def process_batch(timestamp)
      Rails.logger.debug { "Fetching flexible rewards up to #{timestamp}" }
      transactions = client.locked_rewards_history(end_time: timestamp)
        .select { |reward| reward[:time] > last_fetch_timestamp.strftime('%Q').to_i }

      if transactions.empty?
        return nil if timestamp == last_fetch_timestamp

        return [timestamp - 30.days, last_fetch_timestamp].max
      end

      transactions.each { |reward| create_transaction(reward) }
      ensure_progress(transactions, timestamp)
    end

    def ensure_progress(transactions, timestamp)
      last_time = Time.strptime(transactions.last[:time].to_s, '%Q').to_datetime
      last_time -= 1.second if last_time == timestamp
      last_time
    end

    def last_fetch_timestamp
      return @last_fetch_timestamp if defined?(@last_fetch_timestamp)

      timestamp_str = wallet.api_details[TIMESTAMP_KEY]
      date_time = timestamp_str.present? ? DateTime.parse(timestamp_str) : MIN_TIMESTAMP
      @last_fetch_timestamp = date_time
    end

    def start_timestamp
      return @start_timestamp if defined?(@start_timestamp)

      @start_timestamp = Time.current.to_datetime
    end

    def create_transaction(reward)
      wallet.transactions.create!(
        order_id: "#{reward[:asset]}-#{reward[:time]}",
        order_type: 'flexible_reward',
        to_asset: reward[:asset],
        to_amount: reward[:rewards],
        timestamp: Time.strptime(reward[:time].to_s, '%Q')
      )
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.warn "Fetched existing reward transaction, timestamp: #{reward[:time]}, wallet_id: #{wallet.id}}"
    end
  end
end
