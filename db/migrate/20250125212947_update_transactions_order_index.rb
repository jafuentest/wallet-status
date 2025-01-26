class UpdateTransactionsOrderIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :transactions, column: %i[order_id order_type], unique: true

    add_index :transactions, %i[wallet_id order_type order_id], unique: true
    add_index :transactions, %i[wallet_id timestamp], unique: false
  end
end
