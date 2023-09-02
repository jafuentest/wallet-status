module WalletBalanceService::CostBasisCalculator
  FIAT_CURRENCIES = %w[USD EUR GBP RUB]
  def calculate_cost_basis
    scope = user.binance_wallet.transactions.order(timestamp: :asc)
    scope.each do |t|
      break if order_type == 'spot_trade'

      current_cost_basis = get_cost(t.from_amount, t.from_asset)
      raise RuntimeError.new('Missing cost basis of origin asset') if current_cost_basis

      # update from_cost
      # update to_cost

      CostBasisLog.new() unless just_created

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

  def get_current_cost_basis(amount, asset)
    latest_log = user.binance_wallet.cost_basis_logs.where(asset: asset)
      .order(timestamp: :desc)
      .first
      .cost_basis
  end
end
