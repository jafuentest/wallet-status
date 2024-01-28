# == Schema Information
#
# Table name: transactions
#
#  id              :bigint           not null, primary key
#  wallet_id       :bigint           not null
#  from_asset      :string
#  from_amount     :decimal(, )
#  from_cost_basis :decimal(, )
#  to_asset        :string
#  to_amount       :decimal(, )
#  to_cost_basis   :decimal(, )
#  fee_asset       :string
#  fee_amount      :decimal(, )
#  fee_cost_basis  :decimal(, )
#  order_id        :string
#  order_type      :string           not null
#  timestamp       :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Transaction < ApplicationRecord
  belongs_to :wallet

  scope :convertions, -> { where(order_type: 'convert') }
  scope :margin_transfers, -> { where(order_type: 'margin_transfer') }
  scope :spot_trades, -> { where(order_type: 'spot_trade') }
end
