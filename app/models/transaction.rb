class Transaction < ApplicationRecord
  belongs_to :wallet

  scope :convertions, -> { where(order_type: 'convert') }
  scope :margin_transfers, -> { where(order_type: 'margin_transfers') }
  scope :spot_trades, -> { where(order_type: 'spot_trades') }
end
