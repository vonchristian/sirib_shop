class CreateSalesReturns < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_returns do |t|
      t.references :business, null: false, foreign_key: true
      t.references :sales_order, null: false, foreign_key: true
      t.references :customer, foreign_key: true
      t.references :store_location, null: false, foreign_key: true
      t.string :number, null: false
      t.integer :status, null: false, default: 0
      t.text :reason
      t.timestamps
    end

    add_index :sales_returns, [:business_id, :number], unique: true
  end
end
