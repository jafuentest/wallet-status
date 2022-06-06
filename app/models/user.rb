class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :wallets, dependent: :destroy
  has_many :positions, through: :wallets

  def binance_wallet
    wallets.where(service: 'binance').first
  end
end
