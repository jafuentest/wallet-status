class Position < ApplicationRecord
  belongs_to :wallet

  scope :staking, -> { where(sub_wallet: 'staking') }
end
