class CreateTransferOrderLines < ActiveRecord::Migration[8.1]
  def change
    create_table :transfer_order_lines do |t|
      t.references :transfer_order, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, null: false, precision: 12, scale: 3
      t.decimal :received_quantity, null: false, default: 0, precision: 12, scale: 3
      t.timestamps
    end

    add_index :transfer_order_lines, [:transfer_order_id, :product_variant_id]
  end
end
