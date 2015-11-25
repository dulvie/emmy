class SieTransaction < ActiveRecord::Base
  # t.string   :directory
  # t.string   :file
  # t.string   :sie_type
  # t.integer  :execute
  # t.boolean  :complete
  # t.integer  :accounting_period_id
  # t.integer  :user_id
  # t.integer  :organization_id

  attr_accessible :directory, :file, :sie_type, :execute, :complete, :accounting_period,
                  :accounting_period_id, :user, :user_id

  belongs_to :user
  belongs_to :organization
  belongs_to :accounting_period

  def complete?
    complete
  end

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    return if complete?
    Rails.logger.info "->#{inspect}"
    Resque.enqueue(Job::SieTransactionEvent, id)
  end
end
