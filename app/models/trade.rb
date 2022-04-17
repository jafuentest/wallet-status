class Trade < ApplicationRecord
  belongs_to :wallet

  scope :convertions, -> { where(order_type: 'convert') }
  scope :margin_transfers, -> { where(order_type: 'margin_transfers') }
end
