module WalletBalanceService::SpotTrades
  def fetch_pair_trades(symbol, pair)
    retries = 0
    log_spot_trade(pair)

    my_trades = client.my_trades(recvWindow: 60_000, symbol: symbol, orderId: last_spot_trade(symbol))
    my_trades.each { |my_trade| create_transaction_from_spot_trade(my_trade, pair) }

    last_order_id = my_trades.last&.dig(:orderId) || return
    @wallet.update(api_details: @wallet.api_details.merge("#{symbol}_last_spot_order_id" => last_order_id))
  rescue StandardError => e
    Rails.logger.error "Error fetching trades for #{symbol}: #{e}"
    retry if (retries += 1) <= 3
  end

  def fetch_spot_trades
    parent_symbols = %w[bnb btc busd eth others usdc usdt]
    parent_symbols.each { |symbol| fetch_trades_on(symbol) }
  end

  def fetch_trades_on(parent_symbol)
    slices = YAML.load_file(Rails.root.join('config', 'trading_pairs', "#{parent_symbol}.yml"))
    slices = slices.each_pair.reduce({}) { |h, (_k, v)| h.merge(v) } if parent_symbol == 'others'
    run_at = Time.zone.now

    slices.each do |pair|
      Delayed::Job.enqueue fetch_pair_trades(pair[0], pair[1], run_at: run_at)
      run_at += 0.5.seconds
    end
  end

  private

  def available_pairs(parent_symbol, slice_size: nil)
    slices = YAML.load_file(Rails.root.join('config', 'trading_pairs', "#{parent_symbol}.yml"))
    slices = slices.each_pair.reduce({}) { |h, (_k, v)| h.merge(v) } if parent_symbol == 'others'
    return slices if slice_size.nil?

    slices.each_slice(slice_size)
  end

  def log_spot_trade(pair)
    Rails.logger.debug { "Fetching #{pair} spot trades after spot order #{last_spot_trade(pair)}" }
  end

  def last_spot_trade(pair)
    @wallet.api_details["#{pair}_last_spot_order_id"]
  end

  def create_transaction_from_spot_trade(spot_trade, pair)
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
      { from_asset: pair.last, from_amount: transaction_hash[:quoteQty] }
    else
      { from_asset: pair.first, from_amount: transaction_hash[:qty] }
    end
  end

  def to(transaction_hash, pair)
    if transaction_hash[:isBuyer]
      { to_asset: pair.first, to_amount: transaction_hash[:qty] }
    else
      { to_asset: pair.last, to_amount: transaction_hash[:quoteQty] }
    end
  end
end
