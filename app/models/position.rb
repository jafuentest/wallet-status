# == Schema Information
#
# Table name: positions
#
#  id         :bigint           not null, primary key
#  wallet_id  :bigint           not null
#  sub_wallet :string
#  cost_basis :decimal(, )
#  amount     :decimal(, )      not null
#  symbol     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Position < ApplicationRecord
  belongs_to :wallet

  scope :staking, -> { where(sub_wallet: 'staking') }

  with_options(presence: true) do
    validates :amount
    validates :symbol
  end
end
