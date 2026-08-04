# Post balanced, idempotent journal entries to a ledger.
#
# Idempotency for operational events is guaranteed by the caller: events that
# post journal entries run inside a database transaction guarded by a
# compare-and-swap state transition, so the entry is created exactly once.
class JournalPostingService
  class UnbalancedError < StandardError; end

  # lines: array of { account:, debit_cents:, credit_cents:, description: }
  def self.post!(ledger:, reference: nil, description:, occurred_at: Time.current, lines:)
    lines = lines.map(&:symbolize_keys)

    total_debits = lines.sum { |l| l.fetch(:debit_cents, 0) }
    total_credits = lines.sum { |l| l.fetch(:credit_cents, 0) }
    raise UnbalancedError, "debits (#{total_debits}) do not equal credits (#{total_credits})" if total_debits != total_credits
    raise UnbalancedError, "journal entry has no lines" if lines.empty?

    JournalEntry.transaction do
      entry = JournalEntry.new(
        ledger: ledger,
        reference: reference,
        entry_number: next_entry_number(ledger),
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

      entry.save!
      entry
    end
  end

  def self.next_entry_number(ledger)
    date = Time.current.strftime("%Y%m%d")
    prefix = "JE-#{date}-"
    count = JournalEntry.where(ledger: ledger).where("entry_number LIKE ?", "#{prefix}%").count + 1
    "#{prefix}#{count.to_s.rjust(4, "0")}"
  end
end
