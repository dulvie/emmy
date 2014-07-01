class Manual < ActiveRecord::Base
  # t.integer :user_id

  has_one :product_transaction, as: :parent, :dependent => :destroy
  has_one :warehouse, through: :product_transaction
  has_one :product, through: :product_transaction
  belongs_to :user
  has_many :comments, as: :parent, :dependent => :destroy

  validates :product_id, presence: true
  validates :warehouse_id, presence: true
  validates :quantity, presence: true
  
  delegate :quantity, :product_id, :warehouse_id, to: :product_transaction

  def parent_name
    if product_transaction.quantity > 0
      then return "=> " + warehouse.name
    end  
    return warehouse.name + "=> "
  end

  def can_delete?
    true
  end

end
  