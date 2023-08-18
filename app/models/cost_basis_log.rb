class CostBasisLog < ApplicationRecord
  belongs_to :generating_transaction, class_name: 'Transaction', foreign_key: 'transaction_id'
end
