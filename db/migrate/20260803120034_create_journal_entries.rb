class CreateJournalEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_entries do |t|
      t.references :ledger, null: false, foreign_key: true
      t.string :reference_type
      t.bigint :reference_id
      t.string :entry_number, null: false
      t.string :description
      t.datetime :occurred_at, null: false
      t.datetime :posted_at
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :journal_entries, [:ledger_id, :entry_number], unique: true
    add_index :journal_entries, [:reference_type, :reference_id], unique: true,
              where: "status = 1", name: "index_journal_entries_on_reference_posted"
  end
end
