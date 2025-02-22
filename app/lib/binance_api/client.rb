require 'binance'

module BinanceAPI
  class Client
    include BinanceAPI::Account
    include BinanceAPI::Investments
    include BinanceAPI::MarketData
    include BinanceAPI::Trades
    include BinanceAPI::Transfers

    def initialize(key: nil, secret: nil, wallet: nil)
      @client = create_binance_client(key, secret, wallet)
    end

    private

    attr_accessor :client

    def create_binance_client(key, secret, wallet)
      if wallet.present?
        Binance::Spot.new(key: wallet.api_key, secret: wallet.api_secret)
      elsif key.present? && secret.present?
        Binance::Spot.new(key:, secret:)
      else
        raise ArgumentError, 'Either wallet or key and secret must be provided'
      end
    end
  end
end
