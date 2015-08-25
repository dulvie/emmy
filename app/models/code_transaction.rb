class CodeTransaction < ActiveRecord::Base
  # t.string   :directory
  # t.string   :file
  # t.string   :code
  # t.integer  :type
  # t.integer  :accounting_plan_id
  # t.integer  :user_id
  # t.integer  :organization_id

  attr_accessible :directory, :file, :code, :type, :accounting_plan, :accounting_plan_id, :user, :user_id

  belongs_to :user
  belongs_to :organization
  belongs_to :accounting_plan

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    Rails.logger.info "->#{self.inspect}"
    Resque.enqueue(Job::CodeTransactionEvent, id)
  end
end
