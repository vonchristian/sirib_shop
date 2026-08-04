class CreateCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :charges do |t|
      t.references :work_order, null: false, foreign_key: true
      t.string :description, null: false
      t.decimal :quantity, null: false, precision: 12, scale: 3, default: 1
      t.bigint :unit_price_cents, null: false, default: 0
      t.bigint :amount_cents, null: false, default: 0
      t.timestamps
    end
  end
end
