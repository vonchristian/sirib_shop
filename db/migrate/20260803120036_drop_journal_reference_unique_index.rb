class DropJournalReferenceUniqueIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :journal_entries, name: "index_journal_entries_on_reference_posted"
  end
end
