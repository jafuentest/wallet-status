class CostBasisCalculator
  def initialize(user, strategy)
    @user = user
    @strategy = strategy
    @asset_cost_basis_cache = {}
  end

  def calculate
    @user.transactions.order(:timestamp).each do |transaction|
      ActiveRecord::Base.transaction do
        process_transaction(transaction)
      end
    end
  end

  private

  def process_transaction(transaction)
    asset_changes(transaction).each do |change|
      new_cost_basis = @strategy.calculate(
        change[:asset],
        change[:amount],
        asset_cost_basis_for(change[:asset])
      )

      update_cost_basis(new_cost_basis)
    end
  end

  def asset_changes(transaction)
    [
      { amount: transaction.to_amount, asset: transaction.to_asset },
      { amount: -transaction.fee_amount, asset: transaction.fee_asset },
      { amount: -transaction.from_amount, asset: transaction.from_asset },
    ].reject { |e| e[:asset].nil? }
  end

  def asset_cost_basis_for(asset)
    @asset_cost_basis_cache[asset] ||= CostBasis.find_or_initialize_by(user: @user, asset: asset)
  end

  def update_cost_basis(new_cost_basis, amount)
    new_cost_basis.save!

    cost_basis_object = asset_cost_basis_for(new_cost_basis.asset)
    cost_basis_object.total_amount += amount
    cost_basis_object.cost_basis += new_cost_basis.amount
    cost_basis_object.save!
  end
end
