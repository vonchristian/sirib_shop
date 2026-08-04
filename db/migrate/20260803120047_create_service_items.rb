class CreateServiceItems < ActiveRecord::Migration[8.1]
  def change
    create_table :service_items do |t|
      t.references :work_order, null: false, foreign_key: true
      t.string :tag_number, null: false
      t.string :name, null: false
      t.text :description
      t.string :serial_number
      t.decimal :quantity, null: false, precision: 12, scale: 3, default: 1
      t.integer :condition, null: false, default: 0
      t.integer :condition_at_return
      t.text :notes
      t.datetime :received_at, null: false
      t.datetime :returned_at
      t.references :returned_by_user, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :service_items, [:work_order_id, :tag_number], unique: true
    add_index :service_items, [:work_order_id, :returned_at]
  end
end
