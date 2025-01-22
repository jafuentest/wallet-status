module TransactionFetchers::Binance
  class FlexibleReward < Base
    PAGE_SIZE = 10

    def fetch
      timestamp = start_timestamp

      loop do
        log_fetch
        transactions = client.flexible_rewards_history(end_time: timestamp, type: 'ALL')
        transactions.each { |reward| create_transaction(reward) }
        break if transactions.empty? || transactions.size < PAGE_SIZE
        # TODO: Stop on previous fetch's timestamp

        timestamp = transactions.last[:time]
      end

      update_wallet
    end

    private

    def update_wallet
      wallet.update(api_details: wallet.api_details.merge('convertions_last_fetch' => start_timestamp))
    end

    def log_fetch
      Rails.logger.debug { "Fetching flexible rewards up to #{start_timestamp}" }
    end

    def start_timestamp
      return @start_timestamp if defined?(@start_timestamp)

      @start_timestamp = Time.current.to_datetime.strftime('%Q')
    end

    def create_transaction(convertion)
      # TODO
    end

    def log_duplicate_warning(convertion)
      # TODO
    end
  end
end
