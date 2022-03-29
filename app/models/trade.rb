class Trade < ApplicationRecord
  belongs_to :wallet

  scope :convertions, -> { where(order_type: 'convert') }
end
