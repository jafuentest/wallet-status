class FetchSpotTradesJob < ApplicationJob
  def perform(wallet_id, pair)
    wallet = Wallet.find(wallet_id)
    TransactionFetchers::Binance::Spot.new(wallet).fetch_pair(pair)
  end
end
