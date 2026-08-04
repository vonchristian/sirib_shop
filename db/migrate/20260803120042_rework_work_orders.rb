class ReworkWorkOrders < ActiveRecord::Migration[8.1]
  def change
    drop_table :work_orders, if_exists: true

    create_table :work_orders do |t|
      t.references :business, null: false, foreign_key: true
      t.references :store_location, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :service_asset, null: false, foreign_key: true
      t.references :assigned_user, foreign_key: { to_table: :users }
      t.string :number, null: false
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 0
      t.text :complaint
      t.text :diagnosis
      t.text :notes
      t.datetime :received_at, null: false
      t.datetime :promised_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :closed_at
      t.timestamps
    end

    add_index :work_orders, [:business_id, :number], unique: true
    add_index :work_orders, [:business_id, :status]
    add_index :work_orders, [:business_id, :service_asset_id]
    add_index :work_orders, [:store_location_id, :status]
  end
end
