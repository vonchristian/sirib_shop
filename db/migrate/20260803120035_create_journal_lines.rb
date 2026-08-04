class CreateJournalLines < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_lines do |t|
      t.references :journal_entry, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :description
      t.bigint :debit_cents, null: false, default: 0
      t.bigint :credit_cents, null: false, default: 0
      t.timestamps
    end

    add_index :journal_lines, [:journal_entry_id, :account_id]
  end
end
