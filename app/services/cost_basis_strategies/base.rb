module CostBasisStrategies
  class Base
    def initialize(base_currency)
      @base_currency = base_currency
    end

    def calculate(asset, amount, asset_cost_basis)
      raise NotImplementedError
    end

    private

    attr_reader :base_currency
  end
end
