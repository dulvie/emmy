class BankFileTransaction < ActiveRecord::Base
  # t.string   :directory
  # t.string   :file_name
  # t.string   :execute
  # t.boolean  :complete
  # t.integer  :user_id
  # t.integer  :organization_id

  attr_accessible :directory, :file_name, :execute, :path, :user, :user_id

  belongs_to :user
  belongs_to :organization

  def complete?
    return self.complete
  end

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    return if complete?
    Rails.logger.info "->#{self.inspect}"
    Resque.enqueue(Job::BankFileTransactionEvent, id)
  end
end
