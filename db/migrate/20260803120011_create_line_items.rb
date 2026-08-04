class CreateLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :line_items do |t|
      t.references :business, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.integer :movement_type, null: false
      t.decimal :quantity, null: false, precision: 12, scale: 3
      t.bigint :unit_cost_cents, null: false, default: 0
      t.string :reference_type
      t.bigint :reference_id
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :line_items, [:reference_type, :reference_id]
    add_index :line_items, [:stock_id, :occurred_at]
  end
end
