module WalletBalanceService::CostBasisCalculator
  FIAT_CURRENCIES = %w[USD EUR GBP RUB]
  def calculate_cost_basis
    scope = user.binance_wallet.transactions.order(timestamp: :asc)
    scope.each do |t|
      break if order_type == 'spot_trade'

      # Get the cost of the transaction
      t_cost_basis = get_cost(t.from_amount, t.from_asset)
      raise RuntimeError.new('Missing cost basis of origin asset') if t_cost_basis.blank?

      ActiveRecord::Base.transaction do
        # Substract from purchasing asset's cost basis
        unless FIAT_CURRENCIES.include?(t.from_asset)
          latest = latest_asset_log(t.from_asset)
          CostBasisLog.create!(
            generating_transaction: t,
            cost_basis: latest.cost_basis - t_cost_basis,
            total_amount: latest.total_amount - t.from_amount,
            asset: t.from_asset,
            timestamp: t.timestamp
          )
        end

        # Add to purchased asset's cost basis
        latest = latest_asset_log(t.from_asset)
        CostBasisLog.create!(
          generating_transaction: t,
          cost_basis: latest.cost_basis + t_cost_basis,
          total_amount: latest.total_amount + t.to_amount,
          asset: t.to_asset,
          timestamp: t.timestamp
        )

        t.update(from_cost_basis: t_cost_basis, fee_cost_basis: t_cost_basis)
      end
    end
  end

  private

  def get_cost(amount, asset)
    if FIAT_CURRENCIES.include?(asset)
      return asset == 'USD' ? amount : covert_to_usd(amount, asset)
    end

    cost_basis = latest_asset_log(asset)

    cost_basis.unit_cost * amount
  end

  def covert_to_usd(amount, currency)
    # Call some API tbd
    return amount
  end

  def latest_asset_log(asset)
    user.binance_wallet.cost_basis_logs
      .where(asset: asset)
      .order(timestamp: :desc)
      .first
  end
end

# https://github.com/marketplace/actions/simplecov-action
# https://blog.dennisokeeffe.com/blog/2022-03-12-simplecov-with-ruby-and-github-actions
