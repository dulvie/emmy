class Verificate < ActiveRecord::Base
  # t.integer  :number
  # t.string   :state
  # t.datetime :posting_date
  # t.string   :description
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :template_id
  # t.string   :parent_type
  # t.integer  :parent_id
  # t.string   :parent_extend
  # t.integer  :import_bank_file_row_id
  # t.timestamps

  #attr_accessible :posting_date, :description, :accounting_period_id, :reference, :note,
  #                :template_id, :import_bank_file_row_id

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :template
  belongs_to :parent, polymorphic: true
  belongs_to :import_bank_file_row
  has_many   :verificate_items, dependent: :delete_all

  validates :accounting_period_id, presence: true
  validates :description, presence: true
  validate :check_date
  VALID_JOBS = %w(reversal_job)

  def check_date
    if posting_date && (posting_date < accounting_period.accounting_from || posting_date > accounting_period.accounting_to)
      errors.add(:posting_date, I18n.t(:within_period))
    end
  end

  STATE_CHANGES = [:mark_final]

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    send(new_state, changed_at)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_final, do: :generate_verificate_number
    after_transition on: :mark_final, do: :set_dependent
    after_transition on: :mark_final, do: :create_ledger_transactions

    event :mark_final do
      transition preliminary: :final
    end
  end

  def generate_verificate_number(transition)
    return false unless self.balanced?
    self.posting_date = transition.args[0]
    return false if posting_date <  accounting_period.allow_from
    return false if posting_date >  accounting_period.allow_to
    self.number = (Verificate
                       .where(organization_id: organization_id, accounting_period_id: accounting_period_id)
                       .maximum(:number) || 0) + 1
  end

  def set_dependent
    parent.state_change('mark_closed', DateTime.now) if parent_type == 'VatPeriod'
    parent.state_change('mark_wage_closed', DateTime.now) if parent_type == 'WagePeriod' && parent_extend == 'wage'
    parent.state_change('mark_tax_closed', DateTime.now) if parent_type == 'WagePeriod' && parent_extend == 'tax'
    # self.parent.set_posted if self.parent_type == 'ImportBankFileRow'
    import_bank_file_row.set_posted if import_bank_file_row
  end

  def create_ledger_transactions
    verificate_items.each do |verificate_item|
      debit = verificate_item.debit || 0
      credit = verificate_item.credit || 0
      ledger_transaction = LedgerTransaction.new(
          parent: self,
          accounting_period: accounting_period,
          ledger: accounting_period.ledger,
          account: verificate_item.account,
          posting_date: posting_date,
          number: number,
          text: description,
          sum: debit - credit)
      ledger_transaction.organization_id = organization_id
      ledger_transaction.save
    end
  end

  def enqueue_reversal
    logger.info '** Verificate enqueue a job that will create reversal.'
    VerificateJob.perform_later(id, 'reversal_job')
  end

  def reversal_job
    logger.info '** Verificate reversal_job start'
    verificate_creator = Services::VerificateCreator.new(accounting_period, self)

    # create verificate
    ver_dsc = I18n.t(:reversal) + ' ' + I18n.t(:verificate) + ' ' + number.to_s
    verificate_creator.save_verificate(DateTime.now, ver_dsc, '', '', nil, nil)

    # create reversal items
    verificate_items.each do |verificate_item|
      verificate_creator.save_verificate_item(verificate_item.account, verificate_item.credit, verificate_item.debit, verificate_item.result_unit_id)
    end
  end

  def total_debit
    return 0 if verificate_items.count <= 0
    verificate_items.inject(0) { |i, item| (item.debit || 0) + i }
  end

  def bank_amount
    return 0 if final?
    return 0 if verificate_items.count <= 0
    verificate_items.each do |verificate_item|
      if verificate_item.account_number == 1920
        debit = verificate_item.debit || 0
        credit = verificate_item.credit || 0
        return debit - credit
      end
    end
    0
  end

  def total_credit
    return 0 if verificate_items.count <= 0
    verificate_items.inject(0) { |i, item| (item.credit || 0) + i }
  end

  def balanced?
    return false if total_debit == 0
    return false if total_debit != total_credit
    true
  end

  def check_vat_report
    vat = false
    vat_basis = false
    verificate_items.each do |verificate_item|
      if verificate_item.account.tax_code && verificate_item.account.tax_code.vat_purchase
        vat = true
      end
      if verificate_item.tax_code && verificate_item.tax_code.vat_purchase_basis
        vat_basis = true
      end
    end
    return true if vat && vat_basis
    return true if !vat && !vat_basis
    false
  end

  def verificate_items?
    return true if verificate_items.count > 0
    false
  end

  def posting_date_formatted
    return unless posting_date
    posting_date.strftime('%Y-%m-%d')
  end

  def preliminary?
    return true if state == 'preliminary'
    false
  end

  def final?
    return true if state == 'final'
    false
  end

  def can_delete?
    return false if final?
    return false if parent_type? && parent_type != 'ImportBankFileRow'
    true
  end
end
