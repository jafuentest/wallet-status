class CreateCostBasisLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :cost_basis_logs do |t|
      t.references :transaction, null: false, foreign_key: true
      t.float :cost_basis
      t.float :total_amount
      t.string :asset
      t.datetime :timestamp

      t.timestamps

      t.index :asset, unique: true
      t.index :timestamp, unique: true
    end
  end
end
