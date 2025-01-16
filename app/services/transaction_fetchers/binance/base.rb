module TransactionFetchers
  module Binance
    class Base
      def initialize(wallet)
        @client = BinanceClient.new(key: wallet.api_key, secret: wallet.api_secret)
        @wallet = wallet
      end

      protected

      attr_accessor :client, :wallet
    end
  end
end
