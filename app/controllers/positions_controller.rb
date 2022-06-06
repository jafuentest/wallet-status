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

  def staking
    @positions = current_user.positions.staking.sort_by { |e| e[:symbol] }
  end

  def create_staking
    if (@position = current_user.binance_wallet.positions.staking.new).save
      return @alert = { type: :success, message: 'Created' }
    end

    @alert = { type: :error, message: "Error creating staking position: #{@position.errors.to_a.join(', ')}" }
  end

  def update_staking
  end

  def destroy_staking
  end
end
