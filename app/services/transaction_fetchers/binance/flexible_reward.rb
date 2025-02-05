module TransactionFetchers::Binance
  class FlexibleReward < BaseReward
    ORDER_TYPE = 'flexible_reward'.freeze
    PAGE_SIZE = 10
    TIMESTAMP_KEY = 'flexible_last_fetch'.freeze

    def fetch
      timestamp = start_timestamp
      asset_tracker(timestamp).watched_assets
        .each { |asset| fetch_asset(asset, timestamp) }
    end

    def self.amount_key
      :rewards
    end

    def self.order_id_for(reward)
      "#{reward[:asset]}-#{reward[:time]}"
    end

    private

    def fetch_asset(asset, timestamp)
      loop do
        timestamp = process_batch(asset, timestamp)
        break if timestamp.blank?
      end

      wallet.update(api_details: wallet.api_details.merge(TIMESTAMP_KEY => start_timestamp))
    end

    def process_batch(asset, timestamp)
      transactions = fetch_transactions(asset, timestamp)

      if transactions.empty?
        return nil if timestamp == last_fetch_timestamp

        return [timestamp - MAX_TIME_RANGE, last_fetch_timestamp].max
      end

      transactions.each { |reward| create_transaction(reward) }
      ensure_progress(transactions, timestamp)
    end

    def fetch_transactions(asset, timestamp)
      Rails.logger.debug { "Fetching #{asset} flexible rewards up to #{timestamp}" }

      client.flexible_rewards_history(asset:, end_time: timestamp)
        .select { |reward| reward[:time] > last_fetch_timestamp.to_i * 1000 }
    end

    def asset_tracker(timestamp)
      @asset_tracker ||= FlexibleAssetsTracker.new(wallet, start_timestamp: timestamp)
    end

    def transaction_creator
      wallet.transactions.flexible_rewards
    end
  end
end
