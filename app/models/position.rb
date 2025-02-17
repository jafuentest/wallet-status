# == Schema Information
#
# Table name: positions
#
#  id         :bigint           not null, primary key
#  wallet_id  :bigint           not null
#  sub_wallet :string
#  amount     :decimal(, )      not null
#  symbol     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Position < ApplicationRecord
  belongs_to :wallet

  scope :flexible, -> { where(sub_wallet: 'flexible') }
  scope :locked, -> { where(sub_wallet: 'locked') }
  scope :spot, -> { where(sub_wallet: 'spot') }
  scope :staking, -> { where(sub_wallet: 'staking') }
  scope :dual_investment, -> { where(sub_wallet: 'dual_investment') }

  with_options(presence: true) do
    validates :amount
    validates :symbol
  end
end
