require 'binance'

module BinanceAPI
  module MarketData
    include BinanceAPI::Helpers

    def klines(symbol:, start_time:, interval: '1d', limit: 1000)
      safe_api_call { client.klines(symbol:, interval:, limit:, startTime: time_in_format(start_time)) }
    end
    add_method_tracer :klines, 'Custom/BinanceAPI::MarketData#klines'

    def ticker_price
      safe_api_call { client.ticker_price }
    end
    add_method_tracer :ticker_price, 'Custom/BinanceAPI::MarketData#ticker_price'
  end
end
