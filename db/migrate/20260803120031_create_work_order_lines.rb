class CreateWorkOrderLines < ActiveRecord::Migration[8.1]
  def change
    create_table :work_order_lines do |t|
      t.references :work_order, null: false, foreign_key: true
      t.integer :line_type, null: false, default: 0
      t.string :description
      t.references :product_variant, foreign_key: true
      t.decimal :quantity, null: false, default: 1, precision: 12, scale: 3
      t.bigint :unit_price_cents, null: false, default: 0
      t.bigint :total_cents, null: false, default: 0
      t.boolean :consumed, null: false, default: false
      t.timestamps
    end

    add_index :work_order_lines, [:work_order_id, :line_type]
  end
end
