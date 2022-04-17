class CreateWallets < ActiveRecord::Migration[7.0]
  enable_extension 'hstore' unless extension_enabled?('hstore')

  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :service, null: false
      t.string :wallet_type
      t.string :address
      t.hstore :api_details, default: {}
      t.string :api_key
      t.string :api_secret
      t.datetime :last_sync

      t.timestamps
    end
  end
end
