class RemoveUnusedColumnsFromTransactions < ActiveRecord::Migration[7.2]
  def change
    remove_column :transactions, :from_cost_basis, :decimal
    remove_column :transactions, :to_cost_basis, :decimal
    remove_column :transactions, :fee_cost_basis, :decimal
  end
end
