class CreateStocks < ActiveRecord::Migration[8.1]
  def change
    create_table :stocks do |t|
      t.references :business, null: false, foreign_key: true
      t.references :store_location, null: false, foreign_key: true
      t.references :product_variant, null: false, foreign_key: true
      t.decimal :quantity, null: false, default: 0, precision: 12, scale: 3
      t.decimal :reserved_quantity, null: false, default: 0, precision: 12, scale: 3
      t.timestamps
    end

    add_index :stocks, [:store_location_id, :product_variant_id], unique: true
  end
end
