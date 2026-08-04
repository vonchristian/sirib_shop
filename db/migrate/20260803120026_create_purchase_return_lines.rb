class CreatePurchaseReturnLines < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_return_lines do |t|
      t.references :purchase_return, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, null: false, precision: 12, scale: 3
      t.bigint :unit_cost_cents, null: false, default: 0
      t.timestamps
    end

    add_index :purchase_return_lines, [:purchase_return_id, :product_variant_id]
  end
end
