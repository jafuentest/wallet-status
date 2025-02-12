class WalletBalanceService
  POSITION_METHODS = {
    'dual_investment' => :dual_investment_wallet,
    'spot' => :spot_wallet,
    'flexible' => :flexible_wallet,
    'locked' => :locked_wallet,
  }.freeze

  def initialize(user)
    @user = user
    @wallet = user.wallets.where(service: 'binance').first
    @client = BinanceAPI::Client.new(key: @wallet.api_key, secret: @wallet.api_secret)
  end

  def update_positions
    Parallel.map(POSITION_METHODS, in_threads: POSITION_METHODS.size) do |wallet_name, method_name|
      positions = method(method_name).call
      positions.each { |p| persist_position(wallet_name, p) }

      delete_missing_positions(wallet_name, positions.pluck(:asset)) unless wallet_name == 'spot'
    end

    wallet.positions.where(amount: 0).delete_all
  end

  def usd_balances
    @user.positions.select('symbol, SUM(amount) AS amount').group(:symbol).map do |pos|
      price_hash = tickers.find { |e| e[:symbol] == ticker_for(pos) }
      price = price_hash ? price_hash[:price].to_f : 1.0
      pos.attributes.merge(price: price, value: (pos.amount * price).round(2)).symbolize_keys
    end
  end

  def updated_symbols
    %w[usdt busd usdc btc eth bnb others].reduce([]) do |syms, parent_symbol|
      slices = YAML.load_file Rails.root.join('config', 'trading_pairs', "#{parent_symbol}.yml")
      slices = slices.each_pair.reduce({}) { |h, (_k, v)| h.merge(v) } if parent_symbol == 'others'
      syms + slices.map(&:first)
    end
  end

  private

  attr_accessor :client, :user, :wallet

  def spot_wallet
    client.account.select { |e| non_zero_balance?(e) }
  end

  def flexible_wallet
    client.flexible_product_position
  end

  def locked_wallet
    client.locked_product_position
  end

  def dual_investment_wallet
    open_orders = client.dual_investments(status: 'PURCHASE_SUCCESS')
    open_orders.group_by { |h| h[:investCoin] }.map do |e|
      asset, investments = e
      { asset:, amount: investments.sum { |h| h[:subscriptionAmount].to_f } }
    end
  end

  def non_zero_balance?(position)
    position[:amount].positive? ||
      spot_balances.find { |e| e.symbol == position[:asset] }&.amount&.positive?
  end

  def ticker_for(pos)
    "#{pos[:symbol]}USDT"
  end

  def spot_balances
    return @spot_balances if defined? @spot_balances

    @spot_balances = wallet.positions.spot.to_a
  end

  def persist_position(sub_wallet, position)
    pos = wallet.positions.find_or_initialize_by(symbol: position[:asset], sub_wallet:)
    pos.amount = position[:amount]
    pos.save! unless pos.new_record? && pos.amount.zero?
  end

  def delete_missing_positions(sub_wallet, symbols)
    wallet.positions.send(sub_wallet)
      .where.not(symbol: symbols)
      .delete_all
  end

  def tickers
    return @tickers if defined? @tickers

    @tickers = Rails.cache.fetch('tickers', expires_in: 10.minutes) do
      client.ticker_price
    end
  end
end
