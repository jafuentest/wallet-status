class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :from_asset
      t.decimal :from_amount
      t.decimal :from_cost_basis
      t.string :to_asset
      t.decimal :to_amount
      t.decimal :to_cost_basis
      t.string :fee_asset
      t.decimal :fee_amount
      t.decimal :fee_cost_basis
      t.string :order_id
      t.string :order_type, null: false
      t.datetime :timestamp, null: false

      t.timestamps
    end
  end
end


# {
#   symbol: 'BTCUSDT',
#   id: 1338615552,
#   orderId: 10325288904,
#   orderListId: -1,
#   price: '38730.00000000',
#   qty: '0.00015000',
#   quoteQty: '5.80950000',
#   commission: '0.00001125',
#   commissionAsset: 'BNB',
#   time: 1651072734608,
#   isBuyer: true,
#   isMaker: true,
#   isBestMatch: true
# }
