class BalanceTransaction < ActiveRecord::Base
  # t.string   :parent_type
  # t.integer  :parent_id
  # t.string   :execute
  # t.boolean  :complete
  # t.integer  :accounting_period_id
  # t.integer  :user_id
  # t.integer  :organization_id

  attr_accessible :parent, :execute, :accounting_period_id, :user, :user_id

  belongs_to :user
  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :parent, polymorphic: true

  def complete?
    return self.complete
  end

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    return if complete?
    Rails.logger.info "->#{self.inspect}"
    Resque.enqueue(Job::BalanceTransactionEvent, id)
  end
end
