class StakingController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_staking, only: %i[edit update destroy]

  def index
    @positions = current_user.positions.staking.sort_by { |e| e[:symbol] }
  end

  def new
    render partial: 'form_modal', locals: { position: Position.new }
  end

  def edit
    render partial: 'form_modal', locals: { position: @position }
  end

  def create
    @position = current_user.binance_wallet.positions.staking
      .find_or_initialize_by(staking_params.slice(:symbol))

    if @position.persisted?
      flash[:warning] = "Staking for #{staking_params[:symbol]} already exists"
      return redirect_to staking_index_path
    end

    @position.amount = staking_params[:amount]

    if @position.save
      flash[:success] = "Staking position created: #{@position.amount} #{@position.symbol}"
    else
      flash[:warning] = "Error creating staking position: #{@position.errors.to_a.join(', ')}"
    end
    redirect_to staking_index_path
  end

  def update
    @position.update(staking_params)
    flash[:success] = "Staking position updated: #{@position.amount} #{@position.symbol}"
    redirect_to staking_index_path
  end

  def destroy
    flash[:success] = "Staking position removed: #{@position.symbol}"
    @position.destroy
    redirect_to staking_index_path, status: :see_other
  end

  private

  def set_staking
    @position = current_user.binance_wallet.positions.find(params[:id])
  end

  def staking_params
    params.require(:position).permit(:amount, :symbol)
  end
end
