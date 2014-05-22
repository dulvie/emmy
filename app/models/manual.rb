class Manual < ActiveRecord::Base
  # t.integer :user_id

  has_one :product_transaction, as: :parent
  has_one :warehouse, through: :product_transaction
  has_one :product, through: :product_transaction
  belongs_to :user
  has_many :comments, as: :parent

  delegate :quantity, :product_id, :warehouse_id, to: :product_transaction

end
