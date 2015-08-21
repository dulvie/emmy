class AccountingPlanTransaction < ActiveRecord::Base
  # t.datetime :posting_date
  # t.string   :directory
  # t.string   :file
  # t.string   :execute
  # t.integer  :accounting_plan_id
  # t.integer  :user_id
  # t.integer  :organization_id

  attr_accessible :posting_date, :directory, :file, :execute, :accounting_plan, :user, :user_id

  belongs_to :user
  belongs_to :organization

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    Rails.logger.info "->#{self.inspect}"
    Resque.enqueue(Job::AccountingPlanTransactionEvent, id)
  end
end
