class CreateTrades < ActiveRecord::Migration[7.0]
  def change
    create_table :trades do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :from_asset
      t.decimal :from_amount
      t.decimal :from_cost_basis
      t.string :to_asset
      t.decimal :to_amount
      t.decimal :to_cost_basis
      t.datetime :timestamp
      t.string :order_id
      t.string :order_type

      t.timestamps
    end
  end
end
