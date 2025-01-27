module TransactionFetchers::Binance
  class Base < TransactionFetchers::Base
    def initialize(wallet)
      super
      @client = BinanceClient.new(key: wallet.api_key, secret: wallet.api_secret)
    end

    protected

    attr_accessor :client
  end
end
