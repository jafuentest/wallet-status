module TransactionFetchers::Binance
  class Dual < Base
    PAGE_SIZE = 100
    TRANSACTION_TYPE = 'dual_investment'.freeze

    def fetch
      page = 1

      loop do
        Rails.logger.debug { "Fetching dual_investments page ##{page}" }
        orders = client.dual_investments(status: 'SETTLED')
        transactions = orders.map { |order| initialize_transaction(order) }
        insert_result = Transaction.insert_all(transactions) # rubocop:disable Rails/SkipsModelValidations
        break if insert_result.rows.size < PAGE_SIZE

        page += 1
      end
    end

    private

    def job_hash(pair, run_at)
      handler = YAML.dump(Delayed::PerformableMethod.new(self, :fetch_pair, [pair]))

      {
        handler: YAML.dump(handler),
        run_at: run_at,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
        queue: 'default',
      }
    end

    def log_fetch(page)
      Rails.logger.debug { "Fetching dual_investments page ##{page}" }
    end

    def initialize_transaction(order)
      transaction = {
        wallet_id: @wallet.id,
        from_asset: order[:investCoin],
        from_amount: BigDecimal(order[:subscriptionAmount]),
        to_asset: order[:settleAsset],
        to_amount: BigDecimal(order[:settleAmount]),
        order_id: order[:id],
        order_type: TRANSACTION_TYPE,
        timestamp: Time.zone.at(order[:settleDate] / 1000).to_datetime,
      }

      normalize_transaction(transaction)
    end

    def normalize_transaction(transaction)
      return transaction if transaction[:from_asset] != transaction[:to_asset]

      transaction[:to_amount] -= transaction[:from_amount]
      transaction[:from_amount] = 0
      transaction[:from_asset] = nil
      transaction
    end
  end
end
