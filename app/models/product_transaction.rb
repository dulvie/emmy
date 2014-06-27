class ProductTransaction < ActiveRecord::Base
  # t.string :parent_type
  # t.integer :parent_id
  # t.integer :product_id
  # t.integer, :warehouse_id
  # t.integer :quantity

  belongs_to :product
  belongs_to :warehouse
  belongs_to :parent, polymorphic: true

  attr_accessible :warehouse, :warehouse_id, :product, :product_id, :parent_id, :parent, :quantity

  validates :warehouse, presence: true
  validates :product, presence: true
  validates :quantity, presence: true

  after_save :enqueue_event
  after_destroy :enqueue_destroy_event

  # Callback: after_save
  def enqueue_event
    Resque.enqueue(Job::ProductTransactionEvent, self.id)
  end

  def enqueue_destroy_event
    Resque.enqueue(Job::ProductTransactionDestroyEvent, self.warehouse.id, self.product.id)
  end

end
