class CreatePositions < ActiveRecord::Migration[7.0]
  def change
    create_table :positions do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :symbol
      t.string :wallet

      t.timestamps
    end
  end
end
