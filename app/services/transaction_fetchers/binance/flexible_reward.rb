module TransactionFetchers::Binance
  class FlexibleReward < BaseReward
    private

    AMOUNT_KEY = :rewards
    ORDER_TYPE = 'flexible_reward'.freeze
    PAGE_SIZE = 10
    TIMESTAMP_KEY = 'flexible_last_fetch'.freeze

    def fetch_transactions(timestamp)
      Rails.logger.debug { "Fetching flexible rewards up to #{timestamp}" }

      client.flexible_rewards_history(end_time: timestamp)
        .select { |reward| reward[:time] > last_fetch_timestamp.strftime('%Q').to_i }
    end

    def order_id_for(reward)
      "#{reward[:asset]}-#{reward[:time]}"
    end
  end
end
