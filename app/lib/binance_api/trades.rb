require 'binance'

module BinanceAPI
  module Trades
    include BinanceAPI::Helpers

    def my_trades(symbol:, order_id:)
      safe_api_call do
        client.my_trades(**default_params, symbol:, orderId: order_id)
      end
    end
    add_method_tracer :my_trades, 'Custom/BinanceAPI::Trades#my_trades'

    def convert_trade_flow(start_time:, end_time:)
      safe_api_call do
        res = client.convert_trade_flow(
          **default_params,
          startTime: time_in_format(start_time),
          endTime: time_in_format(end_time)
        )

        res[:list]
      end
    end
    add_method_tracer :convert_trade_flow, 'Custom/BinanceAPI::Trades#convert_trade_flow'
  end
end
