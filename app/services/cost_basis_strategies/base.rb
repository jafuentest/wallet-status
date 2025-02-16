module CostBasisStrategies
  class Base
    def initialize(base_currency, binance_client)
      raise ArgumentError, 'Only USD is currently supported for base_currency' unless base_currency == 'USD'

      @base_currency = base_currency
      @binance_client = binance_client
      @market_price_cache = {}
    end

    def calculate(asset, amount, asset_cost_basis)
      raise NotImplementedError
    end

    private

    attr_reader :base_currency

    def fetch_market_price(asset, timestamp)
      date_as_int = timestamp.to_date.to_time.to_i * 1000
      cached_price = @market_price_cache.dig(asset, date_as_int)
      return cached_price unless cached_price.nil?

      symbol = "#{asset}USDT"
      binance_client.klines(symbol:, interval: '1d').each do |kline|
        add_kline_to_cache(kline)
      end
    end

    def add_kline_to_cache(kline)
      open_time = kline[0]
      high_price = BigDecimal(kline[2])
      low_price = BigDecimal(kline[3])
      avg_price = (high_price + low_price) / 2

      @market_price_cache[asset] ||= {}
      @market_price_cache[asset][open_time] = BigDecimal(avg_price)
    end
  end
end
