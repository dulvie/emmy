class BankFileTransaction < ActiveRecord::Base
  # t.string   :parent_type
  # t.integer  :parent_id
  # t.string   :directory
  # t.string   :file_name
  # t.string   :execute
  # t.boolean  :complete
  # t.integer  :user_id
  # t.integer  :organization_id

  attr_accessible :parent, :directory, :file_name, :execute, :path, :user, :user_id

  belongs_to :user
  belongs_to :organization
  belongs_to :parent, polymorphic: true

  def complete?
    complete
  end

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    return if complete?
    Rails.logger.info "->#{inspect}"
    Resque.enqueue(Job::BankFileTransactionEvent, id)
  end
end
