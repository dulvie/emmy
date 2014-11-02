class BatchTransaction < ActiveRecord::Base
  # t.integer :organization_id
  # t.string :parent_type
  # t.integer :parent_id
  # t.integer :batch_id
  # t.integer, :warehouse_id
  # t.integer :quantity

  belongs_to :organization
  belongs_to :batch
  belongs_to :warehouse
  belongs_to :parent, polymorphic: true

  attr_accessible :warehouse, :warehouse_id, :batch, :batch_id, :parent_id, :parent, :quantity, :organization_id

  validates :warehouse, presence: true
  validates :batch, presence: true
  validates :quantity, presence: true

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    Resque.enqueue(Job::BatchTransactionEvent, id)
  end
end
