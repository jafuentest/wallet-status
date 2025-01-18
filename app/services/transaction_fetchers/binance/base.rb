module TransactionFetchers::Binance
  class Base < TransactionFetchers::Base
    def initialize(wallet)
      @wallet = wallet
      super
    end

    protected

    attr_accessor :wallet
  end
end
