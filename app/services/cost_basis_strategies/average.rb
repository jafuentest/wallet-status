module CostBasisStrategies
  class Average < Base
    def calculate(transaction, asset, amount, current_cost_basis)
      new_cost_basis = transaction.cost_basis_changes.new(
        amount: asset_value(asset, amount, transaction.timestamp, current_cost_basis),
        asset: asset,
        quote_currency: base_currency
      )

      current_cost_basis.total_amount += amount
      current_cost_basis.cost_basis += new_cost_basis.amount
      new_cost_basis
    end

    private

    def asset_value(asset, amount, timestamp, current_cost_basis)
      return amount * current_cost_basis.cost_per_unit if amount.negative?

      amount * fetch_market_price(asset, timestamp)
    end
  end
end
