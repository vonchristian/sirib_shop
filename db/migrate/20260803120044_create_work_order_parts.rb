class CreateWorkOrderParts < ActiveRecord::Migration[8.1]
  def change
    create_table :work_order_parts do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.references :stock, foreign_key: true
      t.decimal :quantity, null: false, precision: 12, scale: 3, default: 1
      t.bigint :unit_price_cents, null: false, default: 0
      t.boolean :consumed, null: false, default: false
      t.timestamps
    end
  end
end
