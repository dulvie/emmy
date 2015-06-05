class VerificatTransaction < ActiveRecord::Base
  # t.string   :parent_type
  # t.integer  :parent_id
  # t.integer  :user_id
  # t.integer  :organization_id
  # t.datetime :posting_date
  # t.string   :verificate_type

  attr_accessible :verificate_type, :parent, :posting_date, :user

  belongs_to :user
  belongs_to :organization
  belongs_to :parent, polymorphic: true

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    Rails.logger.info "->#{self.inspect}"
    Resque.enqueue(Job::VerificateTransactionEvent, id)
  end
end
