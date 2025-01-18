module TransactionFetchers::Binance
  class Spot < Base
    def fetch
      run_at = Time.zone.now

      %w[usdt busd usdc btc eth bnb others].each do |parent_symbol|
        slices = YAML.load_file Rails.root.join('config', 'trading_pairs', "#{parent_symbol}.yml")
        slices = slices.each_pair.reduce({}) { |h, (_k, v)| h.merge(v) } if parent_symbol == 'others'

        slices.each do |pair|
          # Spread calls to binance client to prevent API lock from excessive calls
          delay(run_at: run_at += 0.6.seconds).fetch_pair(pair)
        end
      end
    end

    def fetch_pair(trade_pair)
      symbol, pair = trade_pair
      log_fetch(pair)

      my_trades = client.my_trades(recvWindow: 60_000, symbol: symbol, orderId: last_trade(symbol))
      my_trades.each { |my_trade| create_transaction(my_trade, pair) }

      last_order_id = my_trades.last&.dig(:orderId) || return
      @wallet.update(api_details: @wallet.api_details.merge("#{symbol}_last_spot_order_id" => last_order_id))
    rescue StandardError => e
      Rails.logger.error "Error fetching trades for #{symbol}: #{e}"
      raise
    end

    private

    def available_pairs(parent_symbol, slice_size: nil)
      slices = YAML.load_file(Rails.root.join('config', 'trading_pairs', "#{parent_symbol}.yml"))
      slices = slices.each_pair.reduce({}) { |h, (_k, v)| h.merge(v) } if parent_symbol == 'others'
      return slices if slice_size.nil?

      slices.each_slice(slice_size)
    end

    def log_fetch(pair)
      Rails.logger.debug { "Fetching #{pair} spot trades after spot order #{last_trade(pair)}" }
    end

    def last_trade(pair)
      @wallet.api_details["#{pair}_last_spot_order_id"]
    end

    def create_transaction(spot_trade, pair)
      transaction_attributes = assets(spot_trade, pair).merge(
        timestamp: Time.strptime(spot_trade[:time].to_s, '%Q'),
        order_id: spot_trade[:orderId],
        fee_asset: spot_trade[:commissionAsset],
        fee_amount: spot_trade[:commission]
      )

      @wallet.transactions.spot_trades.create!(transaction_attributes)
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.warn "Fetched existing margin trade, order_id: #{spot_trade[:orderId]}, wallet_id: #{@wallet.id}}"
    end

    def assets(transaction_hash, pair)
      from(transaction_hash, pair).merge to(transaction_hash, pair)
    end

    def from(transaction_hash, pair)
      if transaction_hash[:isBuyer]
        {
          from_asset: pair.last,
          from_amount: transaction_hash[:quoteQty],
        }
      else
        {
          from_asset: pair.first,
          from_amount: transaction_hash[:qty],
        }
      end
    end

    def to(transaction_hash, pair)
      if transaction_hash[:isBuyer]
        {
          to_asset: pair.first,
          to_amount: transaction_hash[:qty],
        }
      else
        {
          to_asset: pair.last,
          to_amount: transaction_hash[:quoteQty],
        }
      end
    end
  end
end
