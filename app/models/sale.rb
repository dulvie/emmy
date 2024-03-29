class Sale < ActiveRecord::Base
  # t.integer :user_id
  # t.integer :customer_id
  # t.integer :warehouse_id
  # t.integer :organization_id
  # t.string :contact_email
  # t.string :contact_name
  # t.text    :invoice_text
  # t.integer :payment_term

  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :approved_at
  # t.timestamp :delivered_at
  # t.timestamp :paid_at
  # t.timestamp :canceled_at
  # t.timestamp :sent_email_at
  # t.integer :invoice_number
  # t.datetime :due_date

  STATE_CHANGES = [
    :mark_prepared, :mark_complete, :mark_canceled, # Generic state
    :deliver, # Goods
    :pay,     # Money
  ]

  # For the search filters (/sales/?...)
  FILTER_STAGES=[:meta_complete, :prepared, :cancel, :not_delivered, :not_paid]
  FILTER_STAGES.each do |state|
    case state
    when :not_delivered
      scope state, -> { where(goods_state: state) }
    when :not_paid
      scope state, -> { where(money_state: state) }
    else
      scope state, -> { where(state: state) }
    end
  end

  DEFAULT_PAYMENT_TERM = 30

  belongs_to :user
  belongs_to :customer
  belongs_to :warehouse
  belongs_to :organization
  has_many :sale_items, dependent: :delete_all
  has_many :from_transaction, class_name: 'BatchTransaction', as: :parent
  has_one :document, as: :parent, dependent: :delete
  has_many :comments, as: :parent

  #attr_accessible :warehouse_id, :customer_id, :contact_email, :contact_name, :contact_telephone,
  #                :payment_term, :invoice_text

  attr_accessor :custom_error, :mail_template

  validates :customer_id, presence: true
  validates :warehouse_id, presence: true
  validates :payment_term, numericality: { greater_than: 1, less_than: 365 }
  VALID_JOBS = %w(accounts_receivable_job accounts_receivable_reverse_job customer_payments_job)

  after_initialize :default_values
  after_create :add_invoice_number


  def state_change(new_state, changed_at = nil, report_delivery = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    send(new_state, changed_at, report_delivery)
  end

  def next_step
    case state
    when 'meta_complete'
      :mark_prepared
    when 'prepared'
      :mark_canceled
    when 'canceled' || 'completed'
      nil  
    else
      fail "Unknown state#{state} of sale#{id}"
    end
  end

  state_machine :state, initial: :meta_complete do
    before_transition on: :mark_prepared, do:  :prepare_sale
    after_transition on: :mark_prepared, do: :generate_invoice
    after_transition on: :mark_prepared, do: :enqueue_accounts_receivable
    after_transition on: :mark_prepared, do: :report_delivery
    before_transition on: :mark_canceled, do:  :cancel_sale
    after_transition on: :mark_canceled, do: :create_reverse_transactions
    after_transition on: :mark_canceled, do: :generate_invoice
    after_transition on: :mark_canceled, do: :enqueue_accounts_receivable_reverse

    event :mark_prepared do
      transition meta_complete: :prepared
    end

    event :mark_canceled do
      transition prepared: :canceled
    end

    event :mark_complete do
      transition prepared: :completed
    end
  end

  def prepare_sale(transition)
    self.approved_at = transition.args[0]
    self.approved_at ||= Time.now
    self.due_date = self.approved_at + payment_term.days
  end

  def cancel_sale(transition)
    self.canceled_at = transition.args[0]
    self.canceled_at ||= Time.now
  end

  # @todo refactor this into a job instead.
  def generate_invoice
    d = build_document
    pdf_string = WickedPdf.new.pdf_from_string(
      SalesController.new.render_to_string(
        #template: '/sales/show.pdf.haml',
        template: '/sales/show',
        formats: :pdf,
        layout: 'pdf',
        locale: I18n.locale || I18n.default_locale,
        locals: {
          :@sale => decorate
        }
      ),
      pdf: "invoice_#{id}"
    )

    logger.info 'will try to write to temp file'
    tempfile = Tempfile.new(["invoice_#{id}", '.pdf'], Rails.root.join('tmp'))
    tempfile.binmode
    tempfile.write pdf_string
    logger.info "will now set d.upload = #{tempfile.path} or rather, content of that file"
    d.upload = tempfile
    logger.info 'SAVING!'
    tempfile.close
    tempfile.unlink
    d.save!
  end

  def enqueue_accounts_receivable
    logger.info '** Sale enqueue a job that will create accounts receivable.'
    SaleJob.perform_later(id, 'accounts_receivable_job')
  end

  # Run from the 'SaleJob' model
  def accounts_receivable_job
    logger.info '** Sale accounts_receivable_job start'
    sale_verificate = Services::SaleVerificate.new(self, approved_at)
    unless sale_verificate.valid?
      return
    end
    if sale_verificate.accounts_receivable
      logger.info "** Sale #{id} accounts_receivable verificate returned ok"
    else
      logger.info "** Sale #{id} accounts_receivable verificate did NOT return ok"
    end
  end

  def enqueue_accounts_receivable_reverse
    logger.info '** Sale enqueue a job that will create accounts receivable reverse.'
    SaleJob.perform_later(id, 'accounts_receivable_reverse_job')
  end

  # Run from the 'SaleJob' model
  def accounts_receivable_reverse_job
    logger.info '** Sale accounts_receivable_reverse_job start'
    sale_verificate = Services::SaleVerificate.new(self, approved_at)
    unless sale_verificate.valid?
      return
    end
    if sale_verificate.accounts_receivable_reverse
      logger.info "** Sale #{id} accounts_receivable_reverse verificate returned ok"
    else
      logger.info "** Sale #{id} accounts_receivable_reverse verificate did NOT return ok"
    end
  end

  # include state change of goods_state with mark prepared
  # the condition is checkbox is checked, args[1] is checkbox for reporting deliver
  # sending same date, args[0], as sales marked prepared
  def report_delivery(transition)
    if transition.args[1] == '1'
      send('deliver', transition.args[0])
    end
  end

  state_machine :goods_state, initial: :not_delivered do
    before_transition on: :deliver, do: :deliver_sale
    after_transition on: :deliver, do: :create_from_transactions
    after_transition on: :deliver, do: :check_for_completeness

    event :deliver do
      transition not_delivered: :delivered
    end
  end

  def deliver_sale(transition)
    self.delivered_at = transition.args[0] || Time.now
  end

  def create_from_transactions
    sale_items.each do |sale_item|
      batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: warehouse,
          batch: sale_item.batch,
          quantity: sale_item.quantity * -1)
      batch_transaction.organization_id = organization_id
      batch_transaction.save
    end
  end

  def create_reverse_transactions
    return if goods_state.eql? 'not_delivered'
    sale_items.each do |sale_item|
      batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: warehouse,
          batch: sale_item.batch,
          quantity: sale_item.quantity * 1)
      batch_transaction.organization_id = organization_id
      batch_transaction.save
    end
  end

  state_machine :money_state, initial: :not_paid do
    before_transition on: :pay, do:  :pay_sale
    after_transition on: :pay, do: :enqueue_customer_payments
    after_transition on: :pay, do: :check_for_completeness

    event :pay do
      transition not_paid: :paid
    end
  end

  def pay_sale(transition)
    self.paid_at = transition.args[0] || Time.now
  end

  # After_transition filter for money_state and goods_state.
  def check_for_completeness
    mark_complete if paid? && delivered?
  end

  def enqueue_customer_payments
    logger.info '** Sale enqueue a job that will create customer payments.'
    SaleJob.perform_later(id, 'customer_payments_job')
  end

  # Run from the 'SaleJob' model
  def customer_payments_job
    logger.info '** Sale customer_payments_job start'
    sale_verificate = Services::SaleVerificate.new(self, paid_at)
    unless sale_verificate.valid?
      return
    end
    if sale_verificate.customer_payments
      logger.info "** Sale #{id} customer_payments verificate returned ok"
    else
      logger.info "** Sale #{id} customer_payments verificate did NOT return ok"
    end
  end

  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if ['completed', 'canceled', 'prepared'].include? state
    true
  end

  def completed?
    state.eql? 'completed'
  end

  def delivered?
    goods_state.eql? 'delivered'
  end

  def paid?
    money_state.eql? 'paid'
  end

  def canceled?
    state.eql? 'canceled'
  end

  # Summarize methods.

  # Not sure about the total_* methods, maybe they should go into the decorator...
  def total_price
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| (item.price * item.quantity) + i }
  end

  def total_price_inc_vat
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| item.price_sum + item.total_vat + i }
  end

  def total_vat
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| item.total_vat + i }
  end

  def total_vat_25
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| item.total_vat_25 + i }
  end

  def total_vat_12
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| item.total_vat_12 + i }
  end

  def total_vat_06
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| item.total_vat_06 + i }
  end

  def total_rounding
    return 0 if sale_items.count <= 0
    total_price_inc_vat.round(-2) - total_price_inc_vat
  end

  def total_after_rounding
    total_price_inc_vat.round(-2)
  end

  # Callback: after_create
  # @todo This might have race condition inside, find better solution?
  def add_invoice_number
    return if invoice_number
    #raise RuntimeError if invoice_number
    update_column(:invoice_number, (Sale.where(organization_id: organization_id).maximum(:invoice_number) || 0) +1)
  end

  # @todo move this to a job.
  def send_invoice!(mail_template)
    errors.add(:custom_error, :already_sent) and return false if sent_email_at
    errors.add(:custom_error, :no_customer_email) and return false if contact_email.blank?
    errors.add(:custom_error, :no_organization_email) and return false if organization.email.blank?

    self.sent_email_at = Time.now
    if InvoiceMailer.invoice_email(self, mail_template).deliver
      save
      true
    else
      logger.info "sale#send_invoice!, deliver on InvoiceMailer returned false"
      false
    end
  end

  def send_reminder!(mail_template)
    errors.add(:custom_error, :no_customer_email) and return false if contact_email.blank?
    errors.add(:custom_error, :no_organization_email) and return false if organization.email.blank?

    if InvoiceMailer.reminder_email(self, mail_template).deliver
      save
      true
    else
      logger.info "sale#send_reminder!, deliver on InvoiceMailer returned false"
      false
    end
  end

  def invoice_sent?
    (sent_email_at)
  end

  def overdue?
    return false if paid?
    return false if due_date.nil?
    return false if due_date >= DateTime.now
    true
  end

  def has_document?
    return false if document.nil?
    return true
  end

  # Callback: after_initialize
  def default_values
    self.payment_term = DEFAULT_PAYMENT_TERM
  end

  def parent_name
    '#'+self.invoice_number.to_s
  end
end
