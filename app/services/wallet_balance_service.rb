require 'binance'

class WalletBalanceService
  include WalletBalanceService::Convert
  include WalletBalanceService::Margin
  include WalletBalanceService::SpotTrades

  POSITION_PERSIST_HASH = {
    'spot' => :spot_wallet,
    'flexible' => :flexible_wallet,
    'locked' => :locked_wallet
  }.freeze

  attr_accessor :client

  def initialize(user)
    @user = user
    @wallet = user.wallets.where(service: 'binance').first
    self.client = Binance::Spot.new(key: @wallet.api_key, secret: @wallet.api_secret)
  end

  def update_positions
    Parallel.map(POSITION_PERSIST_HASH) do |wallet, method_name|
      positions = method(method_name).call
      positions.each { |p| persist_position(wallet, p) }

      delete_missing_positions(wallet, positions.pluck(:asset)) unless wallet == 'spot'
    end

    @wallet.positions.where(amount: 0).delete_all
  end

  def usd_balances
    @user.positions.select('symbol, SUM(amount) AS amount').group(:symbol).map do |pos|
      price_hash = tickers.find { |e| e[:symbol] == price(pos) }
      price = price_hash ? price_hash[:price].to_f : 1.0
      pos.attributes.merge(price: price, value: (pos.amount * price).round(2)).symbolize_keys
    end
  end

  def updated_symbols
    symbols = %w[usdt busd usdc btc eth bnb others].reduce([]) do |syms, parent_symbol|
      slices = YAML.load_file Rails.root.join('config', 'trading_pairs', "#{parent_symbol}.yml")
      slices = slices.each_pair.reduce({}) { |h, (_k, v)| h.merge(v) } if parent_symbol == 'others'
      syms << slices.map(&:first)
    end

    symbols.flatten
  end

  private

  def flexible_wallet
    return @flexible_wallet if defined? @flexible_wallet

    @flexible_wallet = client.simple_earn_flexible_position(recvWindow: 60_000, size: 100)[:rows]
    formatted_wallet_data(@flexible_wallet, 'flexible')
  end

  def locked_wallet
    return @locked_wallet if defined? @locked_wallet

    @locked_wallet = client.simple_earn_locked_position(recvWindow: 60_000, size: 100)[:rows]
    formatted_wallet_data(@locked_wallet, 'locked')
  end

  def spot_wallet
    return @spot_wallet if defined? @spot_wallet

    @spot_wallet = client.account(recvWindow: 60_000)[:balances]
      .select { |e| normal_spot_balance?(e) }
      .each { |e| e[:amount] = e[:free].to_f }
  end

  def price(pos)
    traded_against = pos[:symbol] == 'LUNC' ? 'BUSD' : 'USDT'
    "#{pos[:symbol]}#{traded_against}"
  end

  def tickers
    Rails.cache.fetch('tickers', expires_in: 10.minutes) do
      @tickers = client.ticker_price
    end
  end

  def empty_position(asset, amount)
    { asset: asset, free: amount, locked: 0.0 }
  end

  def normal_spot_balance?(position)
    return false if position[:asset].include?('LD')

    position[:free].to_f.positive? ||
      spot_balances.find { |e| e.symbol == position[:asset] }&.amount&.positive?
  end

  def spot_balances
    return @spot_balances if defined? @spot_balances

    @spot_balances = @wallet.positions.spot.to_a
  end

  def formatted_wallet_data(wallet, type = 'flexible')
    amount_key = type == 'flexible' ? :totalAmount : :amount

    wallet.each { |e| e[:amount] = e[amount_key].to_f }
      .map { |e| e.slice(:asset, :amount) }
  end

  def persist_position(wallet, position)
    pos = @wallet.positions.find_or_initialize_by(symbol: position[:asset], sub_wallet: wallet)
    pos.amount = position[:amount]
    pos.save! unless pos.new_record? && pos.amount.zero?
  end

  def delete_missing_positions(wallet, symbols)
    @wallet.positions.send(wallet)
      .where.not(symbol: symbols)
      .delete_all
  end
end
