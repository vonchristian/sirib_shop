class CreateSalesOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_orders do |t|
      t.references :business, null: false, foreign_key: true
      t.references :store_location, null: false, foreign_key: true
      t.references :customer, foreign_key: true
      t.string :number, null: false
      t.integer :status, null: false, default: 0
      t.bigint :subtotal_cents, null: false, default: 0
      t.bigint :discount_total_cents, null: false, default: 0
      t.bigint :tax_total_cents, null: false, default: 0
      t.bigint :total_cents, null: false, default: 0
      t.datetime :ordered_at, null: false
      t.datetime :fulfilled_at
      t.references :created_by_user, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :sales_orders, [:business_id, :number], unique: true
    add_index :sales_orders, [:store_location_id, :ordered_at]
  end
end
