class CreateCashSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :cash_sessions do |t|
      t.references :cash_register, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :opened_at, null: false
      t.datetime :closed_at
      t.bigint :opening_amount_cents, null: false, default: 0
      t.bigint :expected_closing_amount_cents, null: false, default: 0
      t.bigint :actual_closing_amount_cents
      t.bigint :difference_cents
      t.timestamps
    end

    add_index :cash_sessions, [:cash_register_id, :status]
  end
end
