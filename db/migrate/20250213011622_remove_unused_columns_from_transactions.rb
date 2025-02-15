class RemoveUnusedColumnsFromTransactions < ActiveRecord::Migration[7.2]
  def change
    remove_column :positions, :cost_basis, :decimal

    change_table :transactions, bulk: true do |t|
      t.remove :from_cost_basis, type: :decimal
      t.remove :to_cost_basis, type: :decimal
      t.remove :fee_cost_basis, type: :decimal
    end
  end
end
