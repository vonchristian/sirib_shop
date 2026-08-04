class CreateInventoryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_items do |t|
      t.references :business, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.string :serial_number
      t.string :imei_1
      t.string :imei_2
      t.integer :status, null: false, default: 0
      t.datetime :received_at
      t.datetime :sold_at
      t.timestamps
    end

    add_index :inventory_items, [:business_id, :imei_1], unique: true
    add_index :inventory_items, [:business_id, :serial_number], unique: true
    add_index :inventory_items, [:stock_id, :status]
  end
end
