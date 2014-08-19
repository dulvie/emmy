class Sale < ActiveRecord::Base

  # t.integer :user_id
  # t.integer :customer_id
  # t.integer :warehouse_id
  # t.integer :organisation_id
  # t.string :contact_email
  # t.string :contact_name
  # t.integer :payment_term

  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :approved_at
  # t.timestamp :delivered_at
  # t.timestamp :paid_at
  # t.integer :invoice_number
  # t.datetime :due_date

  belongs_to :user
  belongs_to :customer
  belongs_to :warehouse
  belongs_to :organisation
  has_many :sale_items
  has_many :from_transaction, class_name: 'BatchTransaction', as: :parent
  has_one :document, as: :parent

  attr_accessible :user_id, :warehouse_id, :customer_id, :contact_email, :contact_name,
    :payment_term, :state, :approved_at, :goods_state, :delivered_at,
    :money_state,  :paid_at, :invoice_number, :organisation

  validates :customer_id, presence: true
  validates :warehouse_id, presence: true

  # Callbacks
  # @todo Refactor this into service objects instead.
  before_create :ensure_organisation_id

  STATE_CHANGES = [
    :mark_item_complete, :mark_complete, # Generic state
    :deliver, # Goods
    :pay,     # Money
  ]

  def state_change(new_state, changed_at = nil)
   return false unless STATE_CHANGES.include?(new_state.to_sym)
   self.send(new_state, changed_at)
  end

  def next_step
    case state
    when 'meta_complete'
      :mark_item_complete
    when 'item_complete' || 'completed'
      nil
    else
      raise RuntimeError, "Unknown state#{state} of sale#{self.id}"
    end
  end

  state_machine :state, initial: :meta_complete do
    before_transition on: :mark_item_complete, do:  :set_approved_and_due_date
    after_transition on: :mark_item_complete, do: :generate_invoice

    event :mark_item_complete do
      transition :meta_complete => :item_complete
    end

    event :mark_complete do
      transition :item_complete => :completed
    end
  end

  def set_approved_and_due_date(transition)
    self.approved_at = transition.args[0]
    self.approved_at ||= Time.now
    self.due_date = self.approved_at + self.payment_term.days
  end

  # @todo refactor this into a job instead.
  def generate_invoice
    logger.info "I should generate a pdf invoice here..."
    d = self.build_document
    logger.info "ok here comes the wickedpdf line"
    pdf_string = WickedPdf.new.pdf_from_string(
      SalesController.new.render_to_string(
        template: '/sales/show.pdf.haml',
        layout: 'pdf',
        locals: {
          :@sale => self.decorate
        }
      ),
      pdf: "invoice_#{self.id}",
    )
    #logger.info "got a pdf string: #{pdf_string}"

    logger.info "will try to write to temp file"
    tempfile = Tempfile.new(["invoice_#{self.id}", ".pdf"], Rails.root.join('tmp'))
    tempfile.binmode
    tempfile.write pdf_string
    logger.info "will now set d.upload = #{tempfile.path} or rather, content of that file"
    d.upload = tempfile
    logger.info "SAVING!"
    tempfile.close
    #tempfile.unlink
    d.save!
  end


  state_machine :goods_state, initial: :not_delivered do
    before_transition on: :deliver, do: :set_delivered
    after_transition on: :deliver, do: :create_from_transactions
    after_transition on: :deliver, do: :check_for_completeness

    event :deliver do
      transition :not_delivered => :delivered
    end
  end

  def set_delivered(transition)
    self.delivered_at = transition.args[0] || Time.now
  end

  def create_from_transactions
    sale_items.each do |sale_item|
      batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: warehouse,
          batch: sale_item.batch,
          quantity: sale_item.quantity * -1,
          organisation_id: self.organisation_id)
        batch_transaction.save
    end
  end


  state_machine :money_state, initial: :not_paid do
    before_transition on: :pay, do:  :set_paid
    after_transition :not_paid => :paid, do: :check_for_completeness

    event :pay do
      transition :not_paid => :paid
    end
  end

  def set_paid(transition)
    self.paid_at = transition.args[0] || Time.now
  end


  # After_transition filter for money_state and goods_state.
  def check_for_completeness
    if is_paid? and is_delivered?
      self.mark_complete
    end
  end


  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if ['completed','item_complete'].include? state
    true
  end

  def is_completed?
    state.eql? 'completed'
  end

  def is_delivered?
    goods_state.eql? 'delivered'
  end

  def is_paid?
    money_state.eql? 'paid'
  end


  # Summarize methods.

  # Not sure about the total_* methods, maybe they should go into the decorator...
  def total_price
    return 0 if sale_items.count <= 0
    sale_items.inject(0){|i, item| (item.price * item.quantity) + i}
  end

  def total_price_inc_vat
    return 0 if sale_items.count <= 0
    sale_items.inject(0){|i, item| item.price_sum + i}
  end

  def total_vat
    return 0 if sale_items.count <= 0
    sale_items.inject(0){|i, item| item.total_vat + i}
  end

  def invoice_number
    "1000#{self.id}"
  end


  # Callback: before_create
  # @todo Refactor into service object instead.
  def ensure_organisation_id
    org = Organisation.first
    unless org
      raise RuntimeError, "no organisation found!"
    end

    self.organisation_id = org.id
  end

end
