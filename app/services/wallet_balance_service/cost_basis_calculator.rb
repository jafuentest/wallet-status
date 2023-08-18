module WalletBalanceService::CostBasisCalculator
  FIAT_CURRENCIES = %w[USD EUR GBP RUB]
  def calculate_cost_basis
    scope = user.binance_wallet.transactions.order(timestamp: :asc)
    scope.each do |t|
      break if order_type == 'spot_trade'

      operation_cost = get_cost(t.from_amount, t.from_asset)
      # Update cost basis
    end
  end

  private

  def get_cost(amount, asset)
    if FIAT_CURRENCIES.include?(asset)
      return amount if asset == 'USD'

      covert_to_usd(amount, asset)
    else
      get_current_cost_basis(amount, asset)
    end
  end

  def covert_to_usd(amount, currency)
    # Call some API tbd
    return amount
  end

  def get_current_cost_basis(amount, asset)
    latest_log = user.binance_wallet.cost_basis_logs.where(asset: asset)
      .order(timestamp: :desc)
      .first
      .cost_basis
  end
end
