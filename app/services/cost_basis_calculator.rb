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

  def self.average_calculator_for(user)
    api_client = BinanceAPI::Client.new(wallet: user.wallets.first)
    new(user, CostBasisStrategies::Average.new('USD', api_client))
  end

  private

  def process_transaction(transaction)
    asset_changes(transaction).each do |change|
      new_cost_basis = @strategy.calculate(
        transaction,
        change[:asset],
        change[:amount],
        asset_cost_basis_for(change[:asset])
      )

      update_cost_basis(new_cost_basis, change[:amount])
    end
  end

  def asset_changes(transaction)
    changes = [
      { amount: transaction.to_amount, asset: transaction.to_asset },
    ].reject { |e| e[:asset].nil? }

    changes << { amount: -transaction.fee_amount, asset: transaction.fee_asset } if transaction.fee_amount.present?
    changes << { amount: -transaction.from_amount, asset: transaction.from_asset } if transaction.from_amount.present?
    changes
  end

  def asset_cost_basis_for(asset)
    @asset_cost_basis_cache[asset] ||= CostBasis.find_or_initialize_by(user_id: @user.id, asset: asset)
    @asset_cost_basis_cache[asset].tap do |cost_basis|
      cost_basis.total_amount ||= 0
      cost_basis.cost_basis ||= 0
    end
  end

  def update_cost_basis(new_cost_basis, amount)
    new_cost_basis.save!

    cost_basis_object = asset_cost_basis_for(new_cost_basis.asset)
    cost_basis_object.total_amount += amount
    cost_basis_object.cost_basis += new_cost_basis.amount
    cost_basis_object.save!
  end
end
