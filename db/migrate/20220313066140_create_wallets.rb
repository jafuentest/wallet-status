class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :service, null: false
      t.string :wallet_type
      t.string :address
      t.string :api_key
      t.string :api_secret
      t.datetime :last_sync

      t.timestamps
    end
  end
end
