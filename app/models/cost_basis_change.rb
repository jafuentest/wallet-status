# == Schema Information
#
# Table name: cost_basis_changes
#
#  id             :bigint           not null, primary key
#  transaction_id :bigint           not null
#  amount         :float
#  asset          :string
#  quote_currency :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class CostBasisChange < ApplicationRecord
  belongs_to :generating_transaction,
    class_name: 'Transaction',
    foreign_key: 'transaction_id',
    inverse_of: :cost_basis_changes
end
