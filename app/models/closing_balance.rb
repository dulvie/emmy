class ClosingBalance < ActiveRecord::Base
  # t.datetime :posting_date
  # t.string   :description
  # t.string   :state
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.timestamps

  #attr_accessible :description, :accounting_period_id

  belongs_to :organization
  belongs_to :accounting_period
  has_many   :closing_balance_items, dependent: :delete_all

  validates :accounting_period_id, presence: true, uniqueness: { scope: [:organization_id, :accounting_period_id] }
  validates :description, presence: true
  VALID_JOBS = %w(update_from_ledger_job)

  after_commit :enqueue_update_from_ledger_job

  STATE_CHANGES = [:mark_final]

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    send(new_state, changed_at)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_final, do: :set_posting_date

    event :mark_final do
      transition preliminary: :final
    end
  end

  def set_posting_date(transition)
    self.posting_date = transition.args[0]
  end

  def enqueue_update_from_ledger_job
    if final?
      logger.info "** ClosingBalance #{id} is final, will not enqueue_job"
      return
    end
    logger.info '** ClosingBalance enqueue a job that will create UB from ledger.'
    ClosingBalanceJob.perform_later(id, 'update_from_ledger_job')
  end

  # Run from the 'ClosingBalanceJob' model
  def update_from_ledger_job
    return nil if final?
    closing_balance_creator = Services::ClosingBalanceCreator.new(self)
    if closing_balance_creator.update_from_ledger
      logger.info "** ClosingBalance #{id} update_from_ledger returned ok"
    else
      logger.info "** ClosingBalance #{id} update_from_ledger did NOT return ok"
    end
  end

  def total_debit
    return 0 if closing_balance_items.count <= 0
    closing_balance_items.inject(0) { |i, item| (item.debit || 0) + i }
  end

  def total_credit
    return 0 if closing_balance_items.count <= 0
    closing_balance_items.inject(0) { |i, item| (item.credit || 0) + i }
  end

  def can_delete?
    preliminary?
  end
end
