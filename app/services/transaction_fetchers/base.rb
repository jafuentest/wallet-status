module TransactionFetchers
  class Base
    def initialize(wallet)
      @wallet = wallet
    end

    def fetch
      raise NotImplementedError, "#{self.class} must implement `fetch`"
    end

    protected

    attr_accessor :wallet
  end
end
