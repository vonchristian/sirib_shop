class CreatePurchaseOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_orders do |t|
      t.references :business, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.references :destination_store_location, null: false, foreign_key: { to_table: :store_locations }
      t.string :number, null: false
      t.integer :status, null: false, default: 0
      t.bigint :subtotal_cents, null: false, default: 0
      t.bigint :tax_total_cents, null: false, default: 0
      t.bigint :total_cents, null: false, default: 0
      t.datetime :ordered_at, null: false
      t.references :created_by_user, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :purchase_orders, [:business_id, :number], unique: true
  end
end
