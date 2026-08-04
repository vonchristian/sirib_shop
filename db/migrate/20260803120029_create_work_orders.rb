class CreateWorkOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :work_orders do |t|
      t.references :business, null: false, foreign_key: true
      t.references :store_location, null: false, foreign_key: true
      t.references :customer, foreign_key: true
      t.string :number, null: false
      t.integer :status, null: false, default: 0
      t.text :problem_description
      t.text :diagnosis
      t.references :technician_user, foreign_key: { to_table: :users }
      t.datetime :received_at, null: false
      t.datetime :completed_at
      t.datetime :released_at
      t.timestamps
    end

    add_index :work_orders, [:business_id, :number], unique: true
    add_index :work_orders, [:store_location_id, :status]
  end
end
