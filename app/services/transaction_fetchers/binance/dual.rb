module TransactionFetchers::Binance
  class Dual < Base
    PAGE_SIZE = 100
    TRANSACTION_TYPE = 'dual_investment'.freeze

    def fetch
      page = 1

      loop do
        Rails.logger.debug { "Fetching dual_investments page ##{page}" }
        break if process_page(page) < PAGE_SIZE

        page += 1
      end
    end

    private

    def process_page(page)
      transactions = client.dual_investments(status: 'SETTLED', page:)
        .map { |order| transaction_hash(order) }

      rows = transactions.group_by { |t| t[:from_amount].present? }.map do |_exercised, t|
        Transaction.insert_all(t).rows # rubocop:disable Rails/SkipsModelValidations
      end

      rows.sum(&:size)
    end

    def transaction_hash(order)
      normalize_transaction(
        wallet_id: @wallet.id,
        from_asset: order[:investCoin],
        from_amount: BigDecimal(order[:subscriptionAmount]),
        to_asset: order[:settleAsset],
        to_amount: BigDecimal(order[:settleAmount]),
        order_id: order[:id],
        order_type: TRANSACTION_TYPE,
        timestamp: Time.zone.at(order[:settleDate] / 1000).to_datetime
      )
    end

    def normalize_transaction(transaction)
      return transaction if transaction[:from_asset] != transaction[:to_asset]

      transaction[:to_amount] -= transaction.delete(:from_amount)
      transaction.delete(:from_asset)
      transaction
    end
  end
end
