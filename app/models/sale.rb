class Sale < ActiveRecord::Base
  # t.integer :user_id
  # t.integer :customer_id
  # t.integer :warehouse_id
  # t.integer :organization_id
  # t.string :contact_email
  # t.string :contact_name
  # t.integer :payment_term

  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :approved_at
  # t.timestamp :delivered_at
  # t.timestamp :paid_at
  # t.timestamp :sent_email_at
  # t.integer :invoice_number
  # t.datetime :due_date

  scope :prepared, -> { where(state: 'prepared') }
  scope :not_delivered, -> { where(goods_state: 'not_delivered') }

  belongs_to :user
  belongs_to :customer
  belongs_to :warehouse
  belongs_to :organization
  has_many :sale_items, dependent: :delete_all
  has_many :from_transaction, class_name: 'BatchTransaction', as: :parent
  has_one :document, as: :parent, dependent: :delete

  attr_accessible :user_id, :warehouse_id, :customer_id, :contact_email, :contact_name,
                  :payment_term, :state, :approved_at, :goods_state, :delivered_at,
                  :money_state,  :paid_at, :organization, :organization_id, :invoice_number

  validates :customer_id, presence: true
  validates :warehouse_id, presence: true
  validates :payment_term, presence: true

  # Callbacks
  # @todo Refactor this into service objects instead.
  before_create :ensure_organization_id

  after_create :add_invoice_number

  STATE_CHANGES = [
    :mark_prepared, :mark_complete, # Generic state
    :deliver, # Goods
    :pay,     # Money
  ]

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    send(new_state, changed_at)
  end

  def next_step
    case state
    when 'meta_complete'
      :mark_prepared
    when 'prepared' || 'completed'
      nil
    else
      fail "Unknown state#{state} of sale#{id}"
    end
  end

  state_machine :state, initial: :meta_complete do
    before_transition on: :mark_prepared, do:  :prepare_sale
    after_transition on: :mark_prepared, do: :generate_invoice

    event :mark_prepared do
      transition meta_complete: :prepared
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

  # @todo refactor this into a job instead.
  def generate_invoice
    logger.info 'I should generate a pdf invoice here...'
    d = build_document
    logger.info 'ok here comes the wickedpdf line'
    pdf_string = WickedPdf.new.pdf_from_string(
      SalesController.new.render_to_string(
        template: '/sales/show.pdf.haml',
        layout: 'pdf',
        locals: {
          :@sale => decorate
        }
      ),
      pdf: "invoice_#{id}"
    )
    # logger.info "got a pdf string: #{pdf_string}"

    logger.info 'will try to write to temp file'
    tempfile = Tempfile.new(["invoice_#{id}", '.pdf'], Rails.root.join('tmp'))
    tempfile.binmode
    tempfile.write pdf_string
    logger.info "will now set d.upload = #{tempfile.path} or rather, content of that file"
    d.upload = tempfile
    logger.info 'SAVING!'
    tempfile.close
    # tempfile.unlink
    d.save!
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
          quantity: sale_item.quantity * -1,
          organization_id: organization_id)
      batch_transaction.save
    end
  end

  state_machine :money_state, initial: :not_paid do
    before_transition on: :pay, do:  :pay_sale
    after_transition not_paid: :paid, do: :check_for_completeness

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

  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if ['completed', 'prepared'].include? state
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

  # Summarize methods.

  # Not sure about the total_* methods, maybe they should go into the decorator...
  def total_price
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| (item.price * item.quantity) + i }
  end

  def total_price_inc_vat
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| item.price_sum + i }
  end

  def total_vat
    return 0 if sale_items.count <= 0
    sale_items.inject(0) { |i, item| item.total_vat + i }
  end

  # Callback: after_create
  # @todo This might have race condition inside, find better solution?
  def add_invoice_number
    return if invoice_number
    #raise RuntimeError if invoice_number
    update_column(:invoice_number, (Sale.where(organization_id: organization_id).maximum(:invoice_number) || 0) +1)
  end

  # @todo move this to a job.
  def send_invoice!
    return false if sent_email_at

    self.sent_email_at = Time.now
    if InvoiceMailer.invoice_email(self).deliver
      save
    end
  end

  def invoice_sent?
    (sent_email_at)
  end

  def has_document?
    return false if document.nil?
    return true
  end

  # Callback: before_create
  # @todo Refactor into service object instead.
  def ensure_organization_id
    org = Organization.first
    unless org
      fail 'no organization found!'
    end
    self.organization_id = org.id
  end
end
