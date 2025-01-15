require 'binance'

class BinanceClient
  attr_accessor :client

  def initialize(key:, secret:)
    @client = Binance::Spot.new(key:, secret:)
  end

  def account
    client.account(recvWindow: 60_000)[:balances]
      .select { |e| normal_spot_balance?(e) }
      .map { |h| { asset: h[:asset], amount: h.delete(:free).to_f } }
  end

  def dual_investments
    client.dual_investments(status: 'PURCHASE_SUCCESS', recvWindow: 60_000, size: 100)[:list]
      .group_by { |h| h[:investCoin] }.map do |e|
        {
          asset: e.first,
          amount: e.last.sum { |h| h[:subscriptionAmount].to_f }
        }
      end
  end

  def flexible_product_position
    client.flexible_product_position(recvWindow: 60_000, size: 100)[:rows]
      .each_with_object([]) do |h, arr|
        arr << { asset: h[:asset], amount: h[:totalAmount].to_f }
      end
  end

  def locked_product_position
    client.locked_product_position(recvWindow: 60_000, size: 100)[:rows]
      .each_with_object([]) do |h, arr|
        arr << { asset: h[:asset], amount: h[:amount].to_f }
      end
  end

  def tickers
    Rails.cache.fetch('tickers', expires_in: 10.minutes) do
      @tickers = client.ticker_price
    end
  end

  private

  def normal_spot_balance?(position)
    position[:asset].exclude?('LD')
  end
end
