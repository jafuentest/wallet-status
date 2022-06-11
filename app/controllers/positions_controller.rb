class PositionsController < ApplicationController
  before_action :authenticate_user!

  def index
    b = WalletBalanceService.new(current_user)
    @positions = b.usd_balances.sort_by { |e| e[:symbol] }
  end

  def update_wallet
    b = WalletBalanceService.new(current_user)
    b.persist_postitions
    redirect_to positions_path
  end
end
