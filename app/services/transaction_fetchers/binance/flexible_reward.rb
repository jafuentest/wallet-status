module TransactionFetchers::Binance
  class FlexibleReward < Base
    PAGE_SIZE = 10

    def fetch
      timestamp = start_timestamp

      loop do
        timestamp = process_batch(timestamp)
        break if timestamp.blank?
      end

      update_wallet
    end

    private

    def process_batch(timestamp)
      log_fetch(timestamp)
      puts last_fetch_timestamp
      transactions = client.flexible_rewards_history(end_time: timestamp)
        .select { |reward| reward[:time] > last_fetch_timestamp }

      return nil if transactions.empty?

      transactions.each { |reward| create_transaction(reward) }
      ensure_progress(transactions, timestamp)
    end

    def ensure_progress(transactions, timestamp)
      last_time = Time.strptime(transactions.last[:time].to_s, '%Q').to_datetime
      last_time -= 1.second if last_time == timestamp
      last_time
    end

    def update_wallet
      wallet.update(api_details: wallet.api_details.merge('flexible_last_fetch' => start_timestamp))
    end

    def log_fetch(timestamp)
      Rails.logger.debug { "Fetching flexible rewards up to #{timestamp}" }
    end

    def last_fetch_timestamp
      return @last_fetch_timestamp if defined?(@last_fetch_timestamp)

      timestamp_str = wallet.api_details['flexible_last_fetch']
      date_time = timestamp_str.present? ? DateTime.parse(timestamp_str) : DateTime.new
      @last_fetch_timestamp = date_time.strftime('%Q').to_i
    end

    def start_timestamp
      return @start_timestamp if defined?(@start_timestamp)

      @start_timestamp = Time.current.to_datetime
    end

    def create_transaction(reward)
      wallet.transactions.create!(
        order_type: 'flexible_reward',
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
