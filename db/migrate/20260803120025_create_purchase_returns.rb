class CreatePurchaseReturns < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_returns do |t|
      t.references :business, null: false, foreign_key: true
      t.references :purchase_order, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.references :store_location, null: false, foreign_key: true
      t.string :number, null: false
      t.integer :status, null: false, default: 0
      t.text :reason
      t.timestamps
    end

    add_index :purchase_returns, [:business_id, :number], unique: true
  end
end
