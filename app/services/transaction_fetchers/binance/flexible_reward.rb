module TransactionFetchers::Binance
  class FlexibleReward < Base
    PAGE_SIZE = 10

    def fetch
      timestamp = start_timestamp

      loop do
        log_fetch(timestamp)
        transactions = client.flexible_rewards_history(end_time: timestamp, type: 'ALL')
          .select { |reward| reward[:time] > last_fetch_timestamp }

        transactions.each { |reward| create_transaction(reward) }
        break if transactions.empty? || transactions.size < PAGE_SIZE

        timestamp = transactions.last[:time]
      end

      update_wallet
    end

    private

    def update_wallet
      wallet.update(api_details: wallet.api_details.merge('convertions_last_fetch' => start_timestamp))
    end

    def log_fetch(timestamp)
      Rails.logger.debug { "Fetching flexible rewards up to #{timestamp}" }
    end

    def last_fetch_timestamp
      return @last_fetch_timestamp if defined?(@last_fetch_timestamp)

      @last_fetch_timestamp = wallet.api_details['convertions_last_fetch'] || 0
    end

    def start_timestamp
      return @start_timestamp if defined?(@start_timestamp)

      @start_timestamp = Time.current.to_datetime.strftime('%Q')
    end

    def create_transaction(reward)
      wallet.transactions.create!(
        type: 'flexible_reward',
        to_asset: reward[:asset],
        to_amount: reward[:rewards],
        timestamp: Time.strptime(reward[:time].to_s, '%Q')
      )
    rescue ActiveRecord::RecordNotUnique
      log_duplicate_warning(reward)
    end

    def log_duplicate_warning(reward)
      Rails.logger.warn "Fetched existing reward transaction, timestamp: #{reward[:time]}, wallet_id: #{wallet.id}}"
    end
  end
end
