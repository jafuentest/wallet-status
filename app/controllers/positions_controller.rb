class PositionsController < ApplicationController
  before_action :authenticate_user!

  def index
    b = WalletBalanceService.new
    @positions = b.usd_balances(current_user).sort_by { |e| e[:symbol] }
  end

  def update_wallet
    b = WalletBalanceService.new
    b.persist_postitions(current_user)
    redirect_to positions_path
  end
end
