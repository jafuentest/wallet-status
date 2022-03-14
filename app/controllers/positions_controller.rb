class PositionsController < ApplicationController
  before_action :authenticate_user!

  def index
    b = WalletBalanceService.new
    @positions = b.usd_balances(current_user)
  end
end
