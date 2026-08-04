class CreateSalesReturnLines < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_return_lines do |t|
      t.references :sales_return, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, null: false, precision: 12, scale: 3
      t.bigint :unit_price_cents, null: false, default: 0
      t.timestamps
    end

    add_index :sales_return_lines, [:sales_return_id, :product_variant_id]
  end
end
