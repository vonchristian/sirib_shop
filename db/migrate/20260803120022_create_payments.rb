class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :business, null: false, foreign_key: true
      t.references :sales_order, null: false, foreign_key: true
      t.references :cash_session, foreign_key: true
      t.integer :payment_method, null: false, default: 0
      t.bigint :amount_cents, null: false, default: 0
      t.string :reference
      t.integer :status, null: false, default: 0
      t.datetime :paid_at, null: false
      t.timestamps
    end

    add_index :payments, [:sales_order_id, :status]
  end
end
