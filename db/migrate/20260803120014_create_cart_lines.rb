class CreateCartLines < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_lines do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, null: false, default: 1, precision: 12, scale: 3
      t.bigint :unit_price_cents, null: false, default: 0
      t.timestamps
    end

    add_index :cart_lines, [:cart_id, :product_variant_id], unique: true
  end
end
