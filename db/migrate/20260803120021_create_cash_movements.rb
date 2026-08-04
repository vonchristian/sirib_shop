class CreateCashMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :cash_movements do |t|
      t.references :cash_session, null: false, foreign_key: true
      t.integer :movement_type, null: false
      t.bigint :amount_cents, null: false, default: 0
      t.string :reference_type
      t.bigint :reference_id
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :cash_movements, [:reference_type, :reference_id]
  end
end
