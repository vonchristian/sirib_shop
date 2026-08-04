class CreateSalesOrderLines < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_order_lines do |t|
      t.references :sales_order, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, null: false, precision: 12, scale: 3
      t.bigint :unit_price_cents, null: false, default: 0
      t.bigint :discount_cents, null: false, default: 0
      t.bigint :tax_cents, null: false, default: 0
      t.bigint :total_cents, null: false, default: 0
      t.timestamps
    end
  end
end
