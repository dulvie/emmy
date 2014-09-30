class Manual < ActiveRecord::Base
  # t.integer :user_id
  # t.integer :organization_id

  has_one :batch_transaction, as: :parent, dependent: :destroy
  has_one :warehouse, through: :batch_transaction
  has_one :batch, through: :batch_transaction
  belongs_to :user
  belongs_to :organization
  has_many :comments, as: :parent, dependent: :destroy

  # Callbacks
  before_create :check_inventory

  validates :batch_id, presence: true
  validates :warehouse_id, presence: true
  validates :quantity, presence: true
  validates_exclusion_of :quantity, in: 0..0, message: 'Positive or negative quantities'
  validates_associated :comments

  delegate :quantity, :batch_id, :warehouse_id, to: :batch_transaction

  accepts_nested_attributes_for :comments

  # Callback: before_create
  def check_inventory
    if  Inventory.where('warehouse_id = ? AND state = ?', warehouse_id, 'started').count > 0
      errors.add(:warehouse_id, 'Inventory must complete before transfer')
      return false
    else
      return true
    end
  end

  def parent_name
    return '=> ' + warehouse.name if batch_transaction.quantity > 0
    warehouse.name + '=> '
  end

  def can_delete?
    false
  end
end
