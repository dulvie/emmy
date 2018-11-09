class TableTransaction < ActiveRecord::Base
  # t.string   :directory
  # t.string   :file
  # t.string   :execute
  # t.integer  :year
  # t.string   :table
  # t.boolean  :complete
  # t.integer  :user_id
  # t.integer  :organization_id

  #attr_accessible :directory, :file, :execute, :year, :table, :complete, :user, :user_id

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
    Resque.enqueue(Job::TableTransactionEvent, id)
  end
end
