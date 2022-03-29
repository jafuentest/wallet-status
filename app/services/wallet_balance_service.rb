require 'binance'

class WalletBalanceService
  attr_accessor :client

  def initialize(user)
    @user = user
    @wallet = user.wallets.where(service: 'binance').first
    self.client = Binance::Spot.new(key: @wallet.api_key, secret: @wallet.api_secret)
  end

  def mixed_wallet
    @mixed_wallet ||= mix_wallets
  end

  def persist_postitions
    mixed_wallet.each do |e|
      pos = @wallet.positions.find_or_initialize_by(symbol: e[:asset], sub_wallet: 'spot')
      pos.amount = e[:free]
      pos.save!
    end
  end

  def savings_wallet
    @savings_wallet ||= client.savings_account[:positionAmountVos]
      .select { |e| e[:amount].to_f.positive? }
      .each { |e| e[:amount] = e[:amount].to_f }
  end

  def spot_wallet
    @spot_wallet ||= client.account[:balances]
      .select { |e| normal_spot_balance(e) }
      .each { |e| e[:free] = e[:free].to_f }
  end

  def usd_balances
    @user.positions.select('symbol, SUM(amount) AS amount').group(:symbol).map do |pos|
      price_hash = tickers.find { |e| e[:symbol] == "#{pos[:symbol]}USDT" }
      price = price_hash ? price_hash[:price].to_f : 1.0
      pos.attributes.merge(price: price, value: (pos.amount * price).round(2)).symbolize_keys
    end
  end

  def fetch_converts
    loop do
      Rails.logger.debug "Fetching convert trades between #{start_convert} and #{end_convert}"

      break if (Time.now.utc - start_convert) < 1.minute

      converts = client.convert_trade_flow(startTime: start_convert.strftime('%Q'), endTime: end_convert.strftime('%Q'))

      converts[:list].each do |convertion|
        create_trade_from_convertion(convertion) if convertion[:orderStatus] == 'SUCCESS'
      end

      @wallet.update(api_details: @wallet.api_details.merge('convertions_last_fetch' => end_convert))
    end
  end

  private

  def create_trade_from_convertion(convertion)
    @wallet.trades.convertions.create!(
      from_asset: convertion[:fromAsset],
      from_amount: convertion[:fromAmount],
      to_asset: convertion[:toAsset],
      to_amount: convertion[:toAmount],
      timestamp: Time.zone.at(convertion[:createTime] / 1000),
      order_id: convertion[:orderId]
    )
  rescue StandardError # TODO: Should be unique index error, whatever that is
    Rails.logger.warn "Fetched existing trade, order_id: #{convertion[:orderId]}, wallet_id: #{@wallet.id}}"
  end

  def start_convert
    convertions_last_fetch = @wallet.api_details['convertions_last_fetch']
    return Time.utc(2022, 1, 1).to_datetime if convertions_last_fetch.blank?

    DateTime.parse(convertions_last_fetch)
  end

  def end_convert
    [start_convert + 30.days, Time.now.utc.to_datetime].min
  end

  def tickers
    @tickers = client.ticker_price
  end

  def empty_position(asset, amount)
    { asset: asset, free: amount, locked: 0.0 }
  end

  def mix_wallets
    savings_wallet.reduce(spot_wallet.clone) do |spot, e_postion|
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
    position[:free].to_f.positive? && position[:asset].exclude?('LD')
  end
end
