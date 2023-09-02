class CostBasisLog < ApplicationRecord
  belongs_to :generating_transaction, class_name: 'Transaction', foreign_key: 'transaction_id'

  def unit_cost
    total_amount / cost_basis
  end
end
