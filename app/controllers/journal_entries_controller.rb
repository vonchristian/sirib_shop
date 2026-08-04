class JournalEntriesController < ApplicationController
  include MoneyConvertible

  before_action :require_business_user
  before_action :set_journal_entry, only: %i[show reverse]

  def index
    @journal_entries = JournalEntry.includes(:ledger).order(posted_at: :desc, entry_number: :desc)
    if params[:account_id].present?
      @journal_entries = @journal_entries.joins(:journal_lines).where(journal_lines: { account_id: params[:account_id] }).distinct
    end
  end

  def show
    @lines = @journal_entry.journal_lines.includes(:account).order(:id)
  end

  def new
    @accounts = current_ledger.accounts.active.order(:code)
    @ledger = current_ledger
    @journal_entry = JournalEntry.new
    @journal_entry.journal_lines.build
  end

  def create
    @ledger = current_ledger
    @accounts = @ledger.accounts.active.order(:code)

    lines = Array(params[:journal_entry][:lines]).filter_map do |line|
      account = @ledger.accounts.find_by(id: line[:account_id])
      debit = money_value(line[:debit])
      credit = money_value(line[:credit])
      next if account.blank? || (debit.zero? && credit.zero?)

      { account: account, debit_cents: debit, credit_cents: credit, description: line[:description] }
    end

    result = JournalEntryService.create_entry!(
      ledger: @ledger,
      description: params[:journal_entry][:description],
      occurred_at: Time.current,
      lines: lines
    )

    if result.ok
      redirect_to result.entry, notice: "Journal entry posted."
    else
      flash.now[:alert] = result.errors.to_sentence
      @journal_entry = JournalEntry.new
      render :new, status: :unprocessable_entity
    end
  end

  def reverse
    result = JournalEntryService.reverse!(@journal_entry)
    if result.ok
      redirect_to result.entry, notice: "Journal entry reversed."
    else
      redirect_to @journal_entry, alert: result.errors.to_sentence
    end
  end

  private

  def set_journal_entry
    @journal_entry = JournalEntry.find(params[:id])
  end

  def current_ledger
    @ledger ||= AccountingMapper.ledger_for(current_business)
  end
end
