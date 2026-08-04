class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.references :ledger, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :accounts }
      t.string :code, null: false
      t.string :name, null: false
      t.integer :account_type, null: false
      t.integer :normal_balance, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :accounts, [:ledger_id, :code], unique: true
  end
end
