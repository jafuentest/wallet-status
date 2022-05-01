class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :sub_wallet
      t.decimal :cost_basis
      t.decimal :amount, null: false
      t.string :symbol, null: false

      t.timestamps
    end
  end
end
