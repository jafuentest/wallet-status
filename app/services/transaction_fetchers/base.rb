module TransactionFetchers
  class Base
    def initialize(wallet)
      @client = BinanceClient.new(key: wallet.api_key, secret: wallet.api_secret)
    end

    protected

    attr_accessor :client
  end
end
