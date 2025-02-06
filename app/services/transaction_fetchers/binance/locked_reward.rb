module TransactionFetchers::Binance
  class LockedReward < BaseReward
    ORDER_TYPE = 'locked_reward'.freeze
    PAGE_SIZE = 100
    TIMESTAMP_KEY = 'locked_last_fetch'.freeze

    def fetch
      timestamp = start_timestamp

      loop do
        timestamp = process_batch(timestamp)
        break if timestamp.blank?
      end

      wallet.update(api_details: wallet.api_details.merge(self.class::TIMESTAMP_KEY => start_timestamp))
    end

    def self.amount_key
      :amount
    end

    def self.order_id_for(reward)
      "#{reward[:asset]}-#{reward[:positionId]}-#{reward[:time]}"
    end

    private

    def process_batch(timestamp)
      transactions = fetch_transactions(timestamp)

      if transactions.empty?
        return nil if timestamp == last_fetch_timestamp

        return [timestamp - MAX_TIME_RANGE, last_fetch_timestamp].max
      end

      transactions.each { |reward| create_transaction(reward) }
      ensure_progress(transactions, timestamp)
    end

    def fetch_transactions(timestamp)
      Rails.logger.debug { "Fetching locked rewards up to #{timestamp}" }

      client.locked_rewards_history(end_time: timestamp)
        .select { |reward| reward[:time] > last_fetch_timestamp.to_i * 1000 }
    end

    def transaction_creator
      wallet.transactions.locked_rewards
    end
  end
end
