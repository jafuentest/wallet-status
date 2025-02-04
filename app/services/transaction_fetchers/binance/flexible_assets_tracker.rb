module TransactionFetchers::Binance
  class FlexibleAssetsTracker < Base
    def initialize(wallet, start_timestamp:)
      super(wallet)
      @start_timestamp = start_timestamp
    end

    protected

    PAGE_SIZE = 100
    ASSETS_KEY = 'flexible_assets'.freeze
    TIMESTAMP_KEY = 'flexible_last_fetch'.freeze

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
      subscriptions = client.flexible_subscription_record(end_time: timestamp)

      if subscriptions.empty?
        return nil if timestamp == last_fetch_timestamp

        return [timestamp - MAX_TIME_RANGE, last_fetch_timestamp].max
      end

      [
        ensure_progress(subscriptions, timestamp),
        subscriptions.pluck(:asset),
      ]
    end
  end
end
