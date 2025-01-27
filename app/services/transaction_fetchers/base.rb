module TransactionFetchers
  class Base
    def initialize(wallet)
      @wallet = wallet
    end

    protected

    attr_accessor :wallet
  end
end
