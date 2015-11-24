class CodeTransaction < ActiveRecord::Base
  # t.string   :directory
  # t.string   :file
  # t.string   :code
  # t.integer  :run_type
  # t.boolean  :complete
  # t.integer  :accounting_plan_id
  # t.integer  :user_id
  # t.integer  :organization_id

  attr_accessible :directory, :file, :code, :run_type, :complete, :accounting_plan,
                  :accounting_plan_id, :user, :user_id

  belongs_to :user
  belongs_to :organization
  belongs_to :accounting_plan

  def complete?
    complete
  end

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    return if complete?
    Rails.logger.info "->#{inspect}"
    Resque.enqueue(Job::CodeTransactionEvent, id)
  end
end
