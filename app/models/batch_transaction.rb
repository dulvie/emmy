class BatchTransaction < ActiveRecord::Base
  # t.string :parent_type
  # t.integer :parent_id
  # t.integer :batch_id
  # t.integer, :warehouse_id
  # t.integer :quantity

  belongs_to :batch
  belongs_to :warehouse
  belongs_to :parent, polymorphic: true

  attr_accessible :warehouse, :warehouse_id, :batch, :batch_id, :parent_id, :parent, :quantity

  validates :warehouse, presence: true
  validates :batch, presence: true
  validates :quantity, presence: true

  after_save :enqueue_event

  # Callback: after_save
  def enqueue_event
    Resque.enqueue(Job::BatchTransactionEvent, self.id)
  end

end
