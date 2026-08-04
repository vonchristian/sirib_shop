class CreateProductVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :product_variants do |t|
      t.references :business, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :sku, null: false
      t.string :barcode
      t.string :name, null: false
      t.string :unit, null: false, default: "pcs"
      t.bigint :cost_price_cents, null: false, default: 0
      t.bigint :selling_price_cents, null: false, default: 0
      t.boolean :track_serial, null: false, default: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :product_variants, [:business_id, :sku], unique: true
  end
end
