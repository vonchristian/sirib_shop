class CreateWorkOrderServices < ActiveRecord::Migration[8.1]
  def change
    create_table :work_order_services do |t|
      t.references :work_order, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :quantity, null: false, precision: 12, scale: 3, default: 1
      t.bigint :unit_price_cents, null: false, default: 0
      t.timestamps
    end
  end
end
