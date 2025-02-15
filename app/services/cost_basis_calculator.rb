class CostBasisCalculator
  def initialize(user, strategy)
    @user = user
    @strategy = strategy
    @asset_cost_basis_cache = {}
  end

  def calculate
    @user.transactions.order(:timestamp)
      .each { |transaction| process_transaction(transaction) }
  end

  private

  def process_transaction(transaction)
    asset_changes(transaction).each do |change|
      current_cost_basis = asset_cost_basis_for(change[:asset])
      new_cost_basis = @strategy.calculate(change[:asset], change[:amount], current_cost_basis)
      # Update cache
      # Insert in cost basis changes table
    end
    # Persist cache to cost bases table
  end

  def asset_cost_basis_for(asset)
    @asset_cost_basis_cache[asset] ||= CostBasis.find_or_initialize_by(user: @user, asset: asset)
  end

  def asset_changes(transaction)
    [
      { amount: transaction.from_amount, asset: transaction.from_asset },
      { amount: transaction.to_amount, asset: transaction.to_asset },
      { amount: transaction.fee_amount, asset: transaction.fee_asset },
    ].reject { |e| e[:asset].nil? }
  end
end
