require 'binance'

class BinanceClient
  RECV_WINDOW = 60_000

  attr_accessor :client

  def initialize(key: nil, secret: nil, wallet: nil)
    if wallet.present?
      @client = Binance::Spot.new(key: wallet.api_key, secret: wallet.api_secret)
    elsif key.present? && secret.present?
      @client = Binance::Spot.new(key:, secret:)
    else
      raise ArgumentError, 'Either wallet or key and secret must be provided'
    end
  end

  def account
    NewRelic::Agent.disable_all_tracing do
      client.account(recvWindow: RECV_WINDOW)[:balances]
        .select { |e| normal_spot_balance?(e) }
        .map { |h| { asset: h[:asset], amount: h.delete(:free).to_f } }
    end
  end
  add_method_tracer :account, 'Custom/BinanceClient#account'

  def dual_investments
    NewRelic::Agent.disable_all_tracing do
      client.dual_investments(status: 'PURCHASE_SUCCESS', recvWindow: RECV_WINDOW, size: 100)[:list]
        .group_by { |h| h[:investCoin] }.map do |e|
          {
            asset: e.first,
            amount: e.last.sum { |h| h[:subscriptionAmount].to_f },
          }
        end
    end
  end
  add_method_tracer :dual_investments, 'Custom/BinanceClient#dual_investments'

  def flexible_product_position
    NewRelic::Agent.disable_all_tracing do
      client.flexible_product_position(recvWindow: RECV_WINDOW, size: 100)[:rows]
        .each_with_object([]) do |h, arr|
          arr << { asset: h[:asset], amount: h[:totalAmount].to_f }
        end
    end
  end
  add_method_tracer :flexible_product_position, 'Custom/BinanceClient#flexible_product_position'

  def locked_product_position
    NewRelic::Agent.disable_all_tracing do
      client.locked_product_position(recvWindow: RECV_WINDOW, size: 100)[:rows]
        .each_with_object([]) do |h, arr|
          arr << { asset: h[:asset], amount: h[:amount].to_f }
        end
    end
  end
  add_method_tracer :locked_product_position, 'Custom/BinanceClient#locked_product_position'

  def ticker_price
    NewRelic::Agent.disable_all_tracing do
      client.ticker_price
    end
  end
  add_method_tracer :ticker_price, 'Custom/BinanceClient#ticker_price'

  def my_trades(symbol:, order_id:)
    NewRelic::Agent.disable_all_tracing do
      client.my_trades(recvWindow: RECV_WINDOW, symbol:, orderId: order_id)
    end
  end
  add_method_tracer :my_trades, 'Custom/BinanceClient#my_trades'

  def convert_trade_flow(start_time:, end_time:)
    NewRelic::Agent.disable_all_tracing do
      res = client.convert_trade_flow(
        recvWindow: RECV_WINDOW,
        startTime: time_in_format(start_time)
        endTime: time_in_format(end_time)
      )

      res[:list]
    end
  end
  add_method_tracer :convert_trade_flow, 'Custom/BinanceClient#convert_trade_flow'

  def margin_transfer_history(start_time:, end_time:)
    NewRelic::Agent.disable_all_tracing do
      res = client.margin_transfer_history(
        recvWindow: RECV_WINDOW,
        startTime: time_in_format(start_time)
        endTime: time_in_format(end_time)
      )

      res[:rows]
    end
  end
  add_method_tracer :margin_transfer_history, 'Custom/BinanceClient#margin_transfer_history'

  def flexible_rewards_history(end_time: nil)
    NewRelic::Agent.disable_all_tracing do
      res = client.flexible_rewards_history(
        recvWindow: RECV_WINDOW,
        type: 'ALL',
        endTime: time_in_format(end_time)
      )

      res[:rows]
    end
  end
  add_method_tracer :flexible_rewards_history, 'Custom/BinanceClient#flexible_rewards_history'

  private

  def normal_spot_balance?(position)
    position[:asset].exclude?('LD')
  end

  def time_in_format(time)
    time&.strftime('%Q')
  end
end
