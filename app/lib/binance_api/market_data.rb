require 'binance'

module BinanceAPI
  module MarketData
    def ticker_price
      safe_api_call { client.ticker_price }
    end
    add_method_tracer :ticker_price, 'Custom/BinanceClient#ticker_price'
  end
end
