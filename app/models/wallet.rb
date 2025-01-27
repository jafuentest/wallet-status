# == Schema Information
#
# Table name: wallets
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           not null
#  service     :string           not null
#  wallet_type :string           not null
#  address     :string
#  api_details :hstore           not null
#  api_key     :string
#  api_secret  :string
#  last_sync   :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Wallet < ApplicationRecord
  FETCHER_CLASSES = {
    'binance' => [
      TransactionFetchers::Binance::Convertion,
      TransactionFetchers::Binance::FlexibleReward,
      TransactionFetchers::Binance::LockedReward,
      TransactionFetchers::Binance::Margin,
      TransactionFetchers::Binance::Spot,
    ],
  }.freeze

  belongs_to :user
  has_many :positions, dependent: :destroy
  has_many :transactions, dependent: :destroy

  def fetcher_classes
    FETCHER_CLASSES[service]
  end
end
