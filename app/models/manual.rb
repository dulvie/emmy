class Manual < ActiveRecord::Base
  # t.integer :user_id

  has_one :product_transaction, as: :parent, :dependent => :destroy
  has_one :warehouse, through: :product_transaction
  has_one :product, through: :product_transaction
  belongs_to :user
  has_many :comments, as: :parent, :dependent => :destroy

  before_create :check_inventory

  validates :product_id, presence: true
  validates :warehouse_id, presence: true
  validates :quantity, presence: true
  validates_exclusion_of :quantity, :in => 0..0, :message => "Positive or negative quantities"
  validates_associated :comments

  delegate :quantity, :product_id, :warehouse_id, to: :product_transaction

  accepts_nested_attributes_for :comments

  def check_inventory
    if  Inventory.where('warehouse_id = ? AND state = ?', self.warehouse_id, 'started').count > 0
      self.errors.add(:warehouse_id, 'Inventory must complete before transfer')
      return false
    else
      return true
    end
  end

  def parent_name
    if product_transaction.quantity > 0
      then return "=> " + warehouse.name
    end
    return warehouse.name + "=> "
  end

  def can_delete?
    false
  end

end
