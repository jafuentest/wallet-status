module TransactionFetchers::Binance
  class FlexibleReward < BaseReward
    def fetch
      timestamp = start_timestamp
      flexible_assets = watched_assets
      flexible_assets.each { |asset| fetch_asset(asset) }
    end

    private

    AMOUNT_KEY = :rewards
    ORDER_TYPE = 'flexible_reward'.freeze
    PAGE_SIZE = 10
    SUBSCRIPTIONS_PAGE_SIZE = 100
    TIMESTAMP_KEY = 'flexible_last_fetch'.freeze
    TIMESTAMP_KEY_FORMAT = 'flexible_last_fetch_%s'.freeze

    attr_accessor :flexible_assets

    def process_batch(asset, timestamp)
      transactions = fetch_transactions(asset, timestamp)

      if transactions.empty?
        return nil if timestamp == last_fetch_timestamp(key: self.class.timestamp_key_for(asset))

        return [timestamp - TIME_STEP, last_fetch_timestamp(key: self.class.timestamp_key_for(asset))].max
      end

      transactions.each { |reward| create_transaction(reward) }
      ensure_progress(transactions, timestamp)
    end

    def fetch_asset(asset)
      timestamp = start_timestamp

      loop do
        timestamp = process_batch(asset, timestamp)
        break if timestamp.blank?
      end

      key = self.class.timestamp_key_for(asset)
      wallet.update(api_details: wallet.api_details.merge(key => start_timestamp))
    end

    def fetch_transactions(asset, timestamp)
      Rails.logger.debug { "Fetching #{asset} flexible rewards up to #{timestamp}" }

      key = self.class.timestamp_key_for(asset)
      client.flexible_rewards_history(asset:, end_time: timestamp)
        .select { |reward| reward[:time] > last_fetch_timestamp(key:).strftime('%Q').to_i }
    end

    def order_id_for(reward)
      "#{reward[:asset]}-#{reward[:time]}"
    end

    def watched_assets
      assets = wallet.api_details['flexible_assets']
      return initialize_assets if assets.nil?

      assets.split(',')
    end

    def initialize_assets
      self.flexible_assets = Set.new
      timestamp = start_timestamp

      loop do
        timestamp = process_subscription_batch(timestamp)
        break if timestamp.blank?
      end

      wallet.update(api_details: wallet.api_details.merge('flexible_assets' => flexible_assets.to_a.sort.join(',')))
      flexible_assets.to_a
    end

    def process_subscription_batch(timestamp)
      Rails.logger.debug { "Fetching flexible reward subscriptions up to #{timestamp}" }
      subscriptions = client.flexible_subscription_record(end_time: timestamp)
      Rails.logger.debug { "Got #{subscriptions.size} resutls" }

      if subscriptions.empty?
        return nil if timestamp == last_fetch_timestamp

        return [timestamp - TIME_STEP, last_fetch_timestamp].max
      end

      self.flexible_assets.merge subscriptions.pluck(:asset)
      Rails.logger.debug { "Set: #{flexible_assets}" }
      ensure_progress(subscriptions, timestamp, SUBSCRIPTIONS_PAGE_SIZE)
    end

    def self.timestamp_key_for(symbol)
      TIMESTAMP_KEY_FORMAT % symbol
    end
  end
end
