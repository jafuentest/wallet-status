class Wallet < ApplicationRecord
  belongs_to :user
  has_many :positions, dependent: :destroy
  has_many :transactions, dependent: :destroy
end
