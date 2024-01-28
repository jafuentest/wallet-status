require 'binance'

class WalletBalanceService
  include WalletBalanceService::Convert
  include WalletBalanceService::Margin
  include WalletBalanceService::SpotTrades

  attr_accessor :client

  def initialize(user)
    @user = user
    @wallet = user.wallets.where(service: 'binance').first
    self.client = Binance::Spot.new(key: @wallet.api_key, secret: @wallet.api_secret)
  end

  def mixed_wallet
    return @mixed_wallet if defined? @mixed_wallet

    @mixed_wallet = mix_wallets
  end

  def persist_positions
    Parallel.map(%w[spot flexible locked]) do |wallet|
      send(:"#{wallet}_wallet").each do |e|
        pos = @wallet.positions.find_or_initialize_by(symbol: e[:asset], sub_wallet: wallet)
        pos.amount = e[:amount]
        pos.save!
      end
    end
  end

  def flexible_wallet
    return @flexible_wallet if defined? @flexible_wallet

    @flexible_wallet = client.simple_earn_flexible_position(recvWindow: 60_000)[:rows]
      .each { |e| e[:amount] = e[:totalAmount].to_f }
      .map { |e| e.slice(:asset, :amount) }
  end

  def locked_wallet
    return @locked_wallet if defined? @locked_wallet

    @locked_wallet = client.simple_earn_locked_position(recvWindow: 60_000)[:rows]
      .each { |e| e[:amount] = e[:amount].to_f }
      .map { |e| e.slice(:asset, :amount) }
  end

  def spot_wallet
    return @spot_wallet if defined? @spot_wallet

    @spot_wallet = client.account(recvWindow: 60_000)[:balances]
      .select { |e| normal_spot_balance(e) }
      .each { |e| e[:amount] = e[:free].to_f }
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

  def mix_wallets
    flexible_wallet.reduce(spot_wallet.clone) do |spot, e_postion|
      amount = e_postion[:amount].to_f
      s_position = spot.find { |e| e[:asset] == e_postion[:asset] }

      if s_position.nil?
        spot << empty_position(e_postion[:asset], amount)
      else
        s_position[:free] += amount
        spot
      end
    end
  end

  def normal_spot_balance(position)
    return false unless position[:asset].exclude?('LD')

    position[:free].to_f.positive? ||
      @wallet.positions.find_by(symbol: position[:asset])&.amount&.positive?
  end
end
