class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.decimal :amount
      t.string :asset
      t.string :wallet

      t.timestamps
    end
  end
end
