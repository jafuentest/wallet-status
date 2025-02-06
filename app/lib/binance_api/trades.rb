require 'binance'

module BinanceAPI
  module Trades
    def my_trades(symbol:, order_id:)
      safe_api_call do
        client.my_trades(recvWindow: RECV_WINDOW, symbol:, orderId: order_id)
      end
    end
    add_method_tracer :my_trades, 'Custom/BinanceClient#my_trades'

    def convert_trade_flow(start_time:, end_time:)
      safe_api_call do
        res = client.convert_trade_flow(
          recvWindow: RECV_WINDOW,
          startTime: time_in_format(start_time),
          endTime: time_in_format(end_time)
        )

        res[:list]
      end
    end
    add_method_tracer :convert_trade_flow, 'Custom/BinanceClient#convert_trade_flow'
  end
end
