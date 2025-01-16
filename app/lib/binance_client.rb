require 'binance'

class BinanceClient
  RECV_WINDOW = 60_000

  attr_accessor :client

  def initialize(key:, secret:)
    @client = Binance::Spot.new(key:, secret:)
  end

  def account
    client.account(recvWindow: RECV_WINDOW)[:balances]
      .select { |e| normal_spot_balance?(e) }
      .map { |h| { asset: h[:asset], amount: h.delete(:free).to_f } }
  end

  def dual_investments
    client.dual_investments(status: 'PURCHASE_SUCCESS', recvWindow: RECV_WINDOW, size: 100)[:list]
      .group_by { |h| h[:investCoin] }.map do |e|
        {
          asset: e.first,
          amount: e.last.sum { |h| h[:subscriptionAmount].to_f }
        }
      end
  end

  def flexible_product_position
    client.flexible_product_position(recvWindow: RECV_WINDOW, size: 100)[:rows]
      .each_with_object([]) do |h, arr|
        arr << { asset: h[:asset], amount: h[:totalAmount].to_f }
      end
  end

  def locked_product_position
    client.locked_product_position(recvWindow: RECV_WINDOW, size: 100)[:rows]
      .each_with_object([]) do |h, arr|
        arr << { asset: h[:asset], amount: h[:amount].to_f }
      end
  end

  def ticker_price
    Rails.cache.fetch('tickers', expires_in: 10.minutes) do
      @tickers = client.ticker_price
    end
  end

  def my_trades(symbol:, order_id:)
    client.my_trades(recvWindow: RECV_WINDOW, symbol:, orderId: order_id)
  end

  def convert_trade_flow(start_time:, end_time:)
    res = client.convert_trade_flow(
      recvWindow: RECV_WINDOW,
      startTime: start_time.strftime('%Q'),
      endTime: end_time.strftime('%Q')
    )

    res[:list]
  end

  def margin_transfer_history(start_time:, end_time:)
    res = client.margin_transfer_history(
      recvWindow: RECV_WINDOW,
      startTime: start_time.strftime('%Q'),
      endTime: end_time.strftime('%Q')
    )

    res[:rows]
  end

  private

  def normal_spot_balance?(position)
    position[:asset].exclude?('LD')
  end
end
