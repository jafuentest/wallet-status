class Position < ApplicationRecord
  belongs_to :wallet

  scope :staking, -> { where(sub_wallet: 'staking') }

  with_options(presence: true) do
    validates :amount
    validates :symbol
  end
end
