class StockValue < ActiveRecord::Base
  # t.string   :name
  # t.text     :comment
  # t.datetime :value_date
  # t.integer  :value
  # t.integer  :organization_id
  # t.timestamps

  #attr_accessible :name, :comment, :value_date, :value

  belongs_to :organization
  has_many   :stock_value_items, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: [:organization_id] }
  validates :value_date, presence: true

  VALID_JOBS = %w(create_verificate_job)

  STATE_CHANGES = [:mark_reported]

  def state_change(event, changed_at = nil, user_id = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at, user_id)
  end

  state_machine :state, initial: :preliminary do
    before_transition on:  :mark_reported, do: :report
    after_transition on:  :mark_reported, do: :generate_verificate_stock_value

    event :mark_reported do
      transition preliminary: :reported
    end
  end

  def report(transition)
    self.reported_at = transition.args[0]
  end

  def generate_verificate_stock_value(transition)
    enqueue_create_verificate(transition.args[0])
  end

  def enqueue_create_verificate(post_date)
    logger.info '** StockValue enqueue a job that will create verificate.'
    StockValueJob.perform_later(id, 'create_verificate_job', post_date.to_s)
  end

  # Run from the 'Job::StockValueJob' model
  def create_verificate_job(post_date_string)
    post_date = post_date_string.to_date
    logger.info '** StockValue create_verificate_job start'
    stock_value_verificate = Services::StockValueVerificate.new(self, post_date)
    if stock_value_verificate.create
      logger.info "** StockValue #{id} create_verificate returned ok"
    else
      logger.info "** StockValue #{id} create_verificate did NOT return ok"
    end
  end

  def can_edit?
    return false if self.reported?
    true
  end

  def can_delete?
    return false if self.reported?
    true
  end
end
