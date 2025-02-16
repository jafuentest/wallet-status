class CreateCostBasisChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :cost_basis_changes do |t|
      t.references :transaction, null: false, foreign_key: true
      t.decimal :amount
      t.string :asset
      t.string :quote_currency

      t.timestamps

      t.index :asset, unique: false
    end
  end
end
