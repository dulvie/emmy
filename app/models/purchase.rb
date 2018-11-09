class Purchase < ActiveRecord::Base
  # t.integer :organization_id
  # t.integer :parent_id
  # t.string :parent_type

  # t.integer :user_id
  # t.integer :supplier_id
  # t.string :contact_email
  # t.string :contact_name
  # t.string :description
  # t.string  :supplier_reference
  # t.integer :our_reference_id
  # t.integer :to_warehouse_id

  # t.string :state
  # t.string :goods_state
  # t.string :money_state
  # t.timestamp :ordered_at
  # t.timestamp :completed_at
  # t.timestamp :received_at
  # t.timestamp :paid_at
  # t.datetime :due_date

  scope :prepared, -> { where(state: 'prepared') }
  scope :not_paid, -> { where(money_state: 'not_paid') }
  scope :not_received, -> { where(goods_state: 'not_received') }

  belongs_to :organization
  belongs_to :user
  belongs_to :supplier
  belongs_to :our_reference, class_name: 'User'
  belongs_to :to_warehouse, class_name: 'Warehouse'
  belongs_to :parent, polymorphic: true
  has_many :purchase_items, dependent: :delete_all
  has_many :documents, as: :parent, dependent: :delete_all
  has_many :to_transaction, class_name: 'BatchTransaction', as: :parent
  has_many :comments, as: :parent

  accepts_nested_attributes_for :purchase_items

  #attr_accessible :description, :supplier_id, :contact_name, :contact_email, :our_reference_id,
  #                :to_warehouse_id, :ordered_at, :parent_type, :parent_id

  validates :description, presence: true
  validates :supplier_id, presence: true

  VALID_PARENT_TYPES = ['Purchase', 'Production', 'Import']
  VALID_EVENTS = %w(accounts_payable_event supplier_payments_event)

  EVENTS = [
    :mark_prepared, :mark_invoiced, :mark_complete,  # Generic state
    :receive,   # Goods
    :pay,       # Money
  ]

  def state_change(event, changed_at = nil, supplier_reference = nil)
    Rails.logger.info "sc->#{supplier_reference}"
    return false unless EVENTS.include?(event.to_sym)
    send(event, changed_at, supplier_reference)
  end

  def next_event
    case state
    when 'meta_complete'
      :mark_prepared
    when 'prepared' || 'completed'
      nil
    else
      fail 'Unknown state#{state} of purchase#{id}'
    end
  end

  state_machine :state, initial: :meta_complete do
    before_transition on: :mark_prepared, do: :prepare_purchase
    after_transition on: :mark_prepared, do: :enqueue_accounts_payable
    before_transition on: :mark_invoiced, do: :invoice_purchase
    before_transition on: :mark_complete, do: :complete_purchase

    event :mark_prepared do
      transition meta_complete: :prepared
    end

    event :mark_invoiced do
      transition prepared: :invoiced
    end

    event :mark_complete do
      transition invoiced: :completed
    end
  end

  def prepare_purchase(transition)
    self.ordered_at = transition.args[0]
  end

  def enqueue_accounts_payable
    logger.info '** Purchase enqueue a job that will create account payable.'
    Resque.enqueue(Job::PurchaseEvent, id, 'accounts_payable_event')
  end

  # Run from the 'Job::PurchaseEvent' model
  def accounts_payable_event
    logger.info '** Purchase accounts_payable_event start'
    purchase_verificate = Services::PurchaseVerificate.new(self, ordered_at)
    if purchase_verificate.accounts_payable
      logger.info "** Purchase #{id} accounts_payable verificate returned ok"
    else
      logger.info "** Purchase #{id} accounts_payable verificate did NOT return ok"
    end
  end

  def invoice_purchase(transition)
    self.due_date = transition.args[0]
    Rails.logger.info "ip->#{transition.args} #{transition.args[1]}"
    self.supplier_reference = transition.args[1]
  end

  def complete_purchase(transition)
    self.completed_at = transition.args[0]
  end

  state_machine :goods_state, initial: :not_received do
    before_transition on: :receive, do:  :receive_purchase
    after_transition on: :receive, do: :create_to_transactions
    after_transition on: :receive, do: :check_for_completeness

    event :receive do
      transition not_received: :received
    end
  end

  def receive_purchase(transition)
    self.received_at = transition.args[0]
  end

  def create_to_transactions
    purchase_items.each do |purchase_item|
      if purchase_item.item.stocked == true
        batch_transaction = BatchTransaction.new(
          parent: self,
          warehouse: to_warehouse,
          batch: purchase_item.batch,
          quantity: purchase_item.quantity)
        batch_transaction.organization_id = organization_id
        batch_transaction.save
      end
    end
  end

  state_machine :money_state, initial: :not_paid do
    before_transition on: :pay, do: :pay_purchase
    after_transition on: :pay, do: :enqueue_supplier_payments
    after_transition on: :pay, do: :check_for_completeness
    event :pay do
      transition not_paid: :paid
    end
  end

  def pay_purchase(transition)
    self.paid_at = transition.args[0]
  end

  def enqueue_supplier_payments
    logger.info '** Purchase enqueue a job that will create supplier payments.'
    Resque.enqueue(Job::PurchaseEvent, id, 'supplier_payments_event')
  end

  # Run from the 'Job::PurchaseEvent' model
  def supplier_payments_event
    logger.info '** Purchase supplier_payments_event start'
    purchase_verificate = Services::PurchaseVerificate.new(self, paid_at)
    if purchase_verificate.supplier_payments
      logger.info "** Purchase #{id} supplier_payments_verificate returned ok"
    else
      logger.info "** Purchase #{id} supplier_payments_verificate did NOT return ok"
    end
  end

  # after_transition filter for money_state and goods_state.
  def check_for_completeness
    mark_complete(Time.now) if paid? && received?
  end

  def can_edit_items?
    state.eql? 'meta_complete'
  end

  def can_delete?
    return false if ['Production', 'Import'].include? parent_type
    return false if ['prepared', 'invoiced', 'completed'].include? state
    true
  end

  def prepared?
    state.eql? 'prepared'
  end

  def completed?
    state.eql? 'completed'
  end

  def received?
    goods_state.eql? 'received'
  end

  def paid?
    money_state.eql? 'paid'
  end

  def total_amount
    return 0 if purchase_items.count <= 0
    purchase_items.inject(0) { |i, item| item.amount + i }
  end

  def total_vat
    return 0 if purchase_items.count <= 0
    purchase_items.inject(0) { |i, item| item.vat_amount + i }
  end

  def total_exkl_vat
    return 0 if purchase_items.count <= 0
    purchase_items.inject(0) { |i, item| item.amount_exkl_vat + i }
  end

  def parent_name
    description
  end
end
