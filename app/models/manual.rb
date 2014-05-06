class Manual < ActiveRecord::Base
  # t.integer :user_id
  # t.string :state

  has_one :transaction, as: :parent
  has_one :warehouse, through: :transaction
  has_one :product, through: :transaction
  belongs_to :user
  has_many :comments, as: :parent

  delegate :quantity, :product_id, :warehouse_id, to: :transaction

end
