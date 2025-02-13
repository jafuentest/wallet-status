class CreateCostBases < ActiveRecord::Migration[7.2]
  def change
    create_table :cost_bases do |t|
      t.references :user, null: false, foreign_key: true
      t.float :cost_basis
      t.string :asset

      t.timestamps
    end
  end
end
