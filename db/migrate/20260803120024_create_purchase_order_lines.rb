class CreatePurchaseOrderLines < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_order_lines do |t|
      t.references :purchase_order, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, null: false, precision: 12, scale: 3
      t.decimal :received_quantity, null: false, default: 0, precision: 12, scale: 3
      t.bigint :unit_cost_cents, null: false, default: 0
      t.bigint :tax_cents, null: false, default: 0
      t.bigint :total_cents, null: false, default: 0
      t.timestamps
    end

    add_index :purchase_order_lines, [:purchase_order_id, :product_variant_id]
  end
end
