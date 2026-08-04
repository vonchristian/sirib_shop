# Manual journal entry creation and reversal.
#
# Operational entries are posted by their own services via JournalPostingService;
# this service handles ad-hoc entries entered from the UI and reversing a posted
# entry by creating a mirror entry with debits/credits swapped.
class JournalEntryService
  Result = Struct.new(:ok, :entry, :errors, keyword_init: true)

  # lines: array of { account:, debit_cents:, credit_cents:, description: }
  def self.create_entry!(ledger:, description:, occurred_at:, lines:)
    lines = lines.map(&:symbolize_keys)

    total_debits = lines.sum { |l| l.fetch(:debit_cents, 0) }
    total_credits = lines.sum { |l| l.fetch(:credit_cents, 0) }
    return Result.new(ok: false, entry: nil, errors: ["debits must equal credits"]) if total_debits != total_credits
    return Result.new(ok: false, entry: nil, errors: ["journal entry has no lines"]) if lines.empty?

    entry = JournalEntry.new(
      ledger: ledger,
      entry_number: JournalPostingService.next_entry_number(ledger),
      description: description,
      occurred_at: occurred_at,
      posted_at: Time.current,
      status: :posted
    )

    lines.each do |line|
      entry.journal_lines.build(
        account: line.fetch(:account),
        description: line[:description],
        debit_cents: line.fetch(:debit_cents, 0),
        credit_cents: line.fetch(:credit_cents, 0)
      )
    end

    if entry.save
      Result.new(ok: true, entry: entry, errors: [])
    else
      Result.new(ok: false, entry: nil, errors: entry.errors.full_messages)
    end
  end

  def self.reverse!(journal_entry)
    return Result.new(ok: false, entry: journal_entry, errors: ["only posted entries can be reversed"]) unless journal_entry.posted?

    JournalEntry.transaction do
      rows = JournalEntry.where(id: journal_entry.id, status: :posted)
                         .update_all(status: :reversed)
      return Result.new(ok: false, entry: journal_entry, errors: ["entry is not reversible"]) if rows.zero?

      entry = JournalEntry.lock.find(journal_entry.id)

      reversal = JournalEntry.new(
        ledger: entry.ledger,
        reference: entry.reference,
        entry_number: JournalPostingService.next_entry_number(entry.ledger),
        description: "Reversal of #{entry.entry_number}: #{entry.description}",
        occurred_at: Time.current,
        posted_at: Time.current,
        status: :posted
      )

      entry.journal_lines.each do |line|
        reversal.journal_lines.build(
          account: line.account,
          description: "Reversal of #{entry.entry_number}",
          debit_cents: line.credit_cents,
          credit_cents: line.debit_cents
        )
      end

      reversal.save!

      Result.new(ok: true, entry: reversal, errors: [])
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(ok: false, entry: journal_entry, errors: e.record.errors.full_messages)
  end
end
