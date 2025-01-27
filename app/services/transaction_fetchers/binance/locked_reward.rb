module TransactionFetchers::Binance
  class LockedReward < BaseReward
    private

    ORDER_TYPE = 'locked_reward'.freeze
    PAGE_SIZE = 100
    TIMESTAMP_KEY = 'locked_last_fetch'.freeze

    def fetch_transactions(timestamp)
      Rails.logger.debug { "Fetching flexible rewards up to #{timestamp}" }

      client.locked_rewards_history(end_time: timestamp)
        .select { |reward| reward[:time] > last_fetch_timestamp.strftime('%Q').to_i }
    end

    def order_id_for(reward)
      "#{reward[:asset]}-#{reward[:positionId]}-#{reward[:time]}"
    end
  end
end
