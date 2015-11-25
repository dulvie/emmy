class WageTransaction < ActiveRecord::Base
  # t.string   :execute
  # t.boolean  :complete
  # t.integer  :user_id
  # t.integer  :organization_id
  # t.integer  :wage_period_id

  attr_accessible :execute, :complete, :user, :user_id, :wage_period_id

  belongs_to :wage_period
  belongs_to :user
  belongs_to :organization

  def complete?
    complete
  end

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    return if complete?
    Rails.logger.info "->#{inspect}"
    Resque.enqueue(Job::WageTransactionEvent, id)
  end
end
