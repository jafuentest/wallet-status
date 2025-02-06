module TransactionFetchers::Binance
  class FlexibleAssetsTracker < BaseReward
    PAGE_SIZE = 100
    ASSETS_KEY = 'flexible_assets'.freeze
    TIMESTAMP_KEY = 'flexible_last_fetch'.freeze

    def initialize(wallet, start_timestamp:)
      super(wallet)
      @start_timestamp = start_timestamp
    end

    def watched_assets
      assets = @wallet.api_details[ASSETS_KEY]
      return initialize_assets if assets.nil?

      assets.split(',')
    end

    private

    attr_accessor :flexible_assets, :start_timestamp

    def initialize_assets
      flexible_assets = Set.new
      timestamp = start_timestamp

      loop do
        timestamp, assets = process_batch(timestamp)

        flexible_assets.merge(assets)
        break if timestamp.blank?
      end

      assets = flexible_assets.to_a.sort
      wallet.update(api_details: wallet.api_details.merge(ASSETS_KEY => assets.join(',')))
      assets
    end

    def process_batch(timestamp)
      subscriptions = fetch_subscriptions(timestamp)

      if subscriptions.empty?
        return [nil, []] if timestamp == last_fetch_timestamp

        return [[timestamp - MAX_TIME_RANGE, last_fetch_timestamp].max, []]
      end

      [
        ensure_progress(subscriptions, timestamp),
        subscriptions.pluck(:asset),
      ]
    end

    def fetch_subscriptions(timestamp)
      Rails.logger.debug { "Fetching flexible subscriptions up to #{timestamp}" }

      client.flexible_subscription_record(end_time: timestamp)
        .select { |subscription| subscription[:time] > last_fetch_timestamp.to_i * 1000 }
    end
  end
end
