module TransactionFetchers::Binance
  class Base < TransactionFetchers::Base
    # https://www.binance.com/en/support/announcement/binance-exchange-launched-date-set-115000599831
    MIN_TIMESTAMP = Time.utc(2017, 7, 13).to_datetime

    def initialize(wallet)
      super
      @client = BinanceAPI::Client.new(key: wallet.api_key, secret: wallet.api_secret)
    end

    private

    attr_accessor :client
  end
end
